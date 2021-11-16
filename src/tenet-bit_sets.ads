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
generic
   type Element_Type is (<>);

package Tenet.Bit_Sets
is
   type Set is tagged private;
   pragma Preelaborable_Initialization (Character_Set);

   Null_Set: constant Set;
   Full_Set: constant Set;
   
   type Count_Type is
      range
         0 .. Element_Type'Pos (Element_Type'Last) - Element_Type'Pos (Element_Type'Last) + 1;

   subtype Element_Index  is Count_Type range 1 .. Count_Type'Last;
   subtype Ranges_Index   is Count_Type range 1 .. Count_Type'Last;
   subtype Sequence_Index is Count_Type range 1 .. Count_Type'Last;

   function Count (Container: in Set) return Count_Type;

   type Element_Range is
     record
        Low:  Element_Type;
        High: Element_Type;
     end record;

   type Element_Ranges is array (Ranges_Index range <>) of Element_Range;

   function To_Set (Ranges: in Element_Ranges) return Set;

   function To_Set (Span: in Element_Range) return Set;

   function To_Ranges (Container: in Set)  return Element_Ranges;

   function "=" (Left, Right: in Set) return Boolean;

   function "not" (Right: in Set)       return Set; -- inverse
   function "and" (Left, Right: in Set) return Set; -- intersection
   function "or"  (Left, Right: in Set) return Set; -- union
   function "xor" (Left, Right: in Set) return Set; -- symmetric difference
   function "-"   (Left, Right: in Set) return Set; -- difference

   function Is_In (Element:   in Element_Type;
                   Container: in Set)
      return Boolean;

   function Contains (Container: in Set;
                      Element:   in Element_Type)
      return Boolean;

   function Is_Subset (Subset:  in Set;
                       Of_Set: in Set)
      return Boolean;

   function "<=" (Left:  in Set;
                  Right: in Set)
      return Boolean renames Is_Subset;

   type Element_Sequence is array (Sequence_Index range <>) of Element_Type;

   function To_Set (Sequence: in Element_Sequence) return Set;

   function To_Set (Singleton: in Element_Type) return Set;

   function To_Sequence (Container: in Set) return Element_Sequence;

   procedure Include (Container: in out Set; Element: in Element_Type);
   
   procedure Include (Container: in out Set; Span: in Element_Range);
   
   type Element_Mapping is private;
   pragma Preelaborable_Initialization(Element_Mapping);

   function Value (Map:     in Element_Mapping;
                   Element: in Element_Type)
      return Element_Type;

   Identity: constant Element_Mapping;

   function To_Mapping (From, To: in Element_Sequence)
      return Element_Mapping;

   function To_Domain (Map: in Element_Mapping)
      return Set;

   function To_Range  (Map: in Element_Mapping)
      return Set;

   type Mapping_Function is
      access function (From: in Element_Type) return Element_Type;

   procedure Include (Map: in out Mapping; From, To: in Element_Type);
   
private
   type Element_Bitmap is array (Element_Type) of Boolean;

   type Set
   is tagged
      record
         Is_Included: Element_Bitmap := (others => False);
      end record;

   pragma Packed (Set);
   
   Null_Set: constant Set := Set'(Is_Included => (others => False));
   Full_Set: constant Set := Set'(Is_Included => (others => True));
   
   type Mapping_Vector is array (Element_Type) of Element_Type;

   function Identity_Vector return Mapping_Vector
   is
      Result: Mapping_Vector;
   begin
      for E in Element_Type
      loop
         Result (E) := E;
      end loop;
      return Result;
   end;

   type Element_Mapping
   is
      record
         Translation: Mapping_Vector := Identity_Vector;
      end record;
      
   Identity: constant Element_Mapping := Element_Mapping'(Translation => Identity_Vector, 
                                                          Inverse => Identity_Vector);

end;

-------------------------------------------------------------------------------------------------------------------
-- End of file

