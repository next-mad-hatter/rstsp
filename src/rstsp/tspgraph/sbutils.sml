(*
 * $File$
 * $Author$
 * $Date$
 * $Revision$
 *)

structure SBUtils = struct

  structure U = Utils

  local
    structure WordKey = struct
      type ord_key = word
      val compare = Word.compare
    end
    structure WordVectorKey = struct
      type ord_key = word vector
      val compare = Vector.collate Word.compare
    end
  in
    structure WordVectorSet: ORD_SET = SplaySetFn(WordVectorKey)
    structure WordSet: ORD_SET = SplaySetFn(WordKey)
    structure WordMap: ORD_MAP = SplayMapFn(WordKey)
  end

  (**
   * HashedMap: ordered map with keys also stored aside, so that multiple (here: usually two)
   *            keys can point to same (as opposed to equal) items (enter proper items counting etc),
   *            should consist of:
   *              - set of stored items;
   *              - set of keys;
   *              - map from the keys to the items.
   * FIXME: implement a general "doublekeymap" & remove all housekeeping from sbgraph
   * FIXME: can we also have a faster threeMins in sbgraph?
   *)
  datatype ('a,'b) HashedMap = HMAP of 'a * WordSet.set * 'b WordMap.map
  fun getItems (HMAP (x,_,_)) = x
  fun getKeys (HMAP (_,x,_)) = x
  fun getMap (HMAP (_,_,x)) = x

  fun orderInterval (a: word,b) = if a <= b then (a,b) else (b,a)

  fun intervalToList (a: word,b) = if a = b then [a] else [a,b]

  fun pathEnds v =
    if Vector.length v < 2 then raise Fail "No trivial paths allowed." (* [Vector.sub (v,0)] *)
    else (Vector.sub (v,0), Vector.sub (v, (Vector.length v) - 1))

  fun pathEnds' v = let
    val (a,b) = pathEnds v
  in
    [a,b]
  end

  fun mergePaths (v,w) = let
    val (a:word, b:word) = pathEnds v
    val (a':word, b':word) = pathEnds w
    val (v',w') = case (a=a', a=b', b=a', b=b') of
                       (true,_,_,_) => (U.revVector w, v)
                     | (_,true,_,_) => (w, v)
                     | (_,_,true,_) => (v, w)
                     | (_,_,_,true) => (v, U.revVector w)
                     | _ => raise Fail "Merging incompatible paths."
  in
    VectorSlice.concat [VectorSlice.full v', VectorSlice.slice (w',1,NONE)]
  end

end
