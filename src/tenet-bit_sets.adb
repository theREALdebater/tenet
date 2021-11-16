-----------------------------------------------------------------------------------------------
-- This unit is part of Tenet.

-- Copyright (c) 2020 The AdaOS Project

-- Tenet is free software: you can redistribute it and/or modify it under the terms of the 
-- GNU Lesser General Public License as published by the Free Software Foundation, either 
-- version 3 of the License, or (at your option) any later version.

-- Tenet is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
-- See the GNU Lesser General Public License for more details.

-- You should have received a copy of the GNU Lesser General Public License along with 
-- Tenet.  If not, see <https://www.gnu.org/licenses/>.

-- For clarification, "The Library" as defined in the license as it relates to Tenet 
-- comprises the Ada library units whose source text is in a file that contains the words "This 
-- unit is part of Tenet". 

-------------------------------------------------------------------------------------------------------------------
package body Tenet.Bit_Sets
is
   procedure Include (Container: in out Set; Element: in Element_Type)
   is
   begin
      Container.Is_Included (Element) := True;
   end;
   
   procedure Include (Container: in out Set; Span: in Element_Range)
   is
   begin
      Container.Is_Included (Span.From .. Span.To) := (Span.From .. Span.To => True);
   end;
   
   function To_Set (Ranges: in Element_Ranges) return Set
   is
      Result: Set;
   begin
      for R in Ranges
      loop
         Include (Result, R);
      end loop;
      return Result;
   end;

   function To_Set (Span: in Element_Range) return Set
   is
      Result: Set;
   begin
      Include (Result, Span);
      return Result;
   end;

   function To_Ranges (Container: in Set) return Element_Ranges
   is
      package Range_Lists is new Ada.Containers.Doubly_Linked_Lists (Element_Range);
      L: Range_Lists.List; -- initially empty
      R: Element_Range;
      E: Element_Type;
      C: Range_Lists.Cursor;
      i: Element_Count := 0;
   begin
      R.From := Element_Type'First;
      loop
         if Container.Is_Included (R.From)
         then
            E := R.From;
            R.To := E;
            while E /= Element_Type'Last
            loop
               E := Element_Type'Succ (E);
               exit when not Container.Is_Included (E);
               R.To := E;
            end loop;
            L.Append (R);
            exit when R.To = Element_Type'Last;
            R.From := Element_Type'Succ (R.To);
         else
            exit when R.From = Element_Type'Last;
            R.From := Element_Type'Succ (R.From);
         end if;
      end loop;
      return Result: Element_Ranges (1 .. Element_Count (L.Length))
      do
         C := L.First;
         while C /= Element_Lists.No_Element
         loop
            i := i + 1;
            Result (i) := Element (C);
            Next (C);
         end loop;
         pragma Assert (i = Element_Count (L.Length));         
      end return;
   end;

   function "=" (Left, Right: in Set) return Boolean
   is
      (Left.Is_Included = Right.Is_Included);

   function "not" (Right: in Set) return Set -- inverse
   is
      (Set'(Is_Included => not Right.Is_Included));
   
   function "and" (Left, Right: in Set) return Set -- intersection
   is
      (Set'(Is_Included => Left.Is_Included and Right.Is_Included));

   function "or"  (Left, Right: in Set) return Set -- union
   is
      (Set'(Is_Included => Left.Is_Included or Right.Is_Included));
   
   function "xor" (Left, Right: in Set) return Set -- symmetric difference
   is
      (Set'(Is_Included => Left.Is_Included xor Right.Is_Included));
   
   function "-" (Left, Right: in Set) return Set -- difference
   is
      (Set'(Is_Included => Left.Is_Included and not Right.Is_Included));

   function Is_In (Element:   in Element_Type;
                   Container: in Set)
      return Boolean
   is
      (Container.Is_Included (Element));

   function Contains (Container: in Set;
                      Element:   in Element_Type)
      return Boolean
   is
      (Container.Is_Included (Element));

   function Is_Subset (Subset:  in Set;
                       Of_Set: in Set)
      return Boolean
   is
      (Of_Set.Is_Included and Subset.Is_Included /= Element_Bitmap'(others => False));

   function To_Set (Sequence: in Element_Sequence) return Set
   is
      Result: Set;
   begin
      for E of Element_Sequence
      loop
         Result.Include (E);
      end loop;
      return Result;
   end;

   function To_Set (Singleton: in Element_Type) return Set
   is
      (Set'(Is_Included => Element_Bitmap'(Singleton => True, others => False)));

   function Cardinality (Container: in Set) return Count_Type
   is
      Count: Count_Type := 0;
   begin
      for E in Element_Type
      loop
         if Container.Is_Included (E) then Count := @ + 1; end if;
      end loop;
      return Count;
   end;

   function To_Sequence (Container: in Set) return Element_Sequence
   is
      Result: Element_Sequence (1 .. Cardinality (Container));
      i: Count_Type := 0;
   begin
      for E in Element_Type
      loop
         if Container.Is_Included (E)
         then
            i := i + 1;
            Result (i) := E;
         end if;      
      end loop;
      pragma Assert (i = Cardinality (Container)); -- TODO: Too expensive?
      return Result;
   end;

   function Value (Map:     in Element_Mapping;
                   Element: in Element_Type)
      return Element_Type
   is
      (Map.Translation (Element));

   function To_Mapping (From, To: in Element_Sequence)
      return Element_Mapping
   is
      Result: Element_Mapping;
      i1: Sequence_Index := From'First;
      i2: Sequence_Index := To'First;
   begin
      if From'Length /= To'Length then raise Constraint_Error; end if;
      loop
         Result.Include (Result, From (i1), To (i2));
         exit when i1 = From'Last;
         i1 := i1 + 1;
         i2 := i2 + 1;
      end loop;
      pragma Assert (i2 = To'Last);
      return Result;
   end;

   function To_Domain (Map: in Element_Mapping)
      return Set
   is
      S: Set;
   begin
      for E in Element_Type
      loop
         if Map.Translation (E) /= E then Include (S, E); end if;
      end loop;
      return S;
   end;

   function To_Range (Map: in Element_Mapping)
      return Set
   is
      S: Set;
   begin
      for E in Element_Type
      loop
         if Map.Translation (E) /= E then Include (S, Map.Translation (E)); end if;
      end loop;
      return S;
   end;

   procedure Include (Map: in out Mapping; From, To: in Element_Type)
   is
   begin
      Map.Translation (From) := To;
   end;
   
end Tenet.Bit_Sets;

-------------------------------------------------------------------------------------------------------------------
-- End of file

