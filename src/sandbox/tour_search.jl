#!/usr/bin/julia
#
# $Id$
# $Author$
# $Date$
# $Rev: 34 $
#

#
# Elements
#

#dist = [
#  0 1 2 3;
#  1 0 1 2;
#  2 1 0 1;
#  3 2 1 0;
#]

dist = [
  0 0 0 0 4 0 0;
  0 0 8 5 6 1 0;
  0 8 0 17 16 10 8;
  0 5 17 0 34 27 24;
  4 6 16 34 0 4 0;
  0 1 10 27 4 0 0;
  0 0 8 24 0 0 0
]

#dist = [
#  0 0  0  0  0  7  0;
#  0 0  11 8  5  11 3;
#  0 11 0  9  4  9  0;
#  0 8  9  0  6  10 0;
#  0 5  4  6  0  11 0;
#  7 11 9  10 11 0  0;
#  0 3  0  0  0  0  0;
#]

function tour_len(t)
  if length(t) < 2
    return 0
  else
    reduce( (s,x) -> (s[1] + dist[s[2],x],x), (0,t[end]), t)[1]
  end
end


#
# Bal. search
#

  min3 = x -> map(y -> Set([y[1],y[end]]), x) |>
              y -> reduce(union,y) |>
              collect |> sort |>
              y -> y[1:minimum([3, length(y)])]

  attach(a, x) = if a[1] < a[end] vcat(x,a) else vcat(a,x) end

  function merge(a, b, m)
    if a[1] < a[end] a = reverse(a) end
    if b[1] > b[end] b = reverse(b) end
    vcat(a,m,b)
  end

function bal_tour(l, debug=false)

  function insert(ts, ms, offset=1)
    if isempty(ms)
      ts
    else
      just = ^(" ",offset*2)
      if debug
        println(just,"****")
        print(just,ts)
        print(" <- ")
        println(ms)
      end

      m = first(ms)
      js = min3(ts)

      cs = map(j -> filter(y->in(j,y), ts) |> first, js)

      ss = Set([])
      if length(ts) < length(ms)
        ss = union(ss,
          insert(union(ts, Set({[m]})), setdiff(ms,m), offset+1))
      end
      if length(ts) <= length(ms)
        ss = union(ss,
          insert(union(setdiff(ts, Set({cs[1]})), Set({attach(cs[1],m)})), setdiff(ms,m), offset+1))
      end

      if(length(js)>1 && cs[1] != cs[2])
        ss = union(ss,
          insert(union(setdiff(ts, Set({cs[1],cs[2]})), Set({merge(cs[1],cs[2],m)})), setdiff(ms,m), offset+1))
      end
      if(length(js)>2 && cs[1] != cs[3])
        ss = union(ss,
          insert(union(setdiff(ts, Set({cs[1],cs[3]})), Set({merge(cs[1],cs[3],m)})), setdiff(ms,m), offset+1))
      end

      # FIXME: necessary?
      #ss = filter(x -> length(x) <= length(ms), ss)
      r = reduce((x,y) -> if tour_len(x) < tour_len(y) x else y end, ss)
      if debug
        println(just,r," (",tour_len(r),")")
      end
      Set({r})
    end
  end

  insert(Set({[1]}), 2:l) |> first
end

println("*** BAL ***")
t = bal_tour(size(dist,1), true)
println(t)
println(tour_len(t))

#
# Exh. search
#

println("*** EXH ***")
p = collect(permutations(1:size(dist,1)))
r = map(tour_len, p)
m = minimum(r)
is = find(x -> x==m, r)
for i in is
  println(p[i])
end
println(r[first(is)])

