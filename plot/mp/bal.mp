%
% $Author$
% $File$
% $Date$
% $Revision$
%

input cmarrows
input metaobj
% in tex: latexmp + textext OR standalone: this
verbatimtex
%&latex
  \documentclass{article}
  \usepackage{mathdesign}
  \usepackage{amsmath}
  \usepackage{amssymb}
  \usepackage{lmodern}
  \begin{document}
etex;
prologues := 3;

vardef xdotlabel@#(expr s, c) text p =
  label.@#(s,c);
  draw c p;
enddef;

beginfig(1)
  numeric u;
  u = 2.81mm;
  dx = 5u;
  dy = 1.4u;
  if outputformat="eps":
    %796045
    drawoptions(withcolor (121/255,96/255,69/255));
  else:
    outputformat := "eps";
  fi;
  for i = 1 upto 7:
    x[i] = i * dx;
  endfor
  y[1] := 2.5*dy;
  y[2] := 1*dy;
  y[3] := 3.4*dy;
  y[4] := 1.5*dy;
  y[5] := 2.0*dy;
  y[6] := 2.8*dy;
  y[7] =  2.9*dy;
  for i = 1 upto 7:
    draw (x[i],y[i]) withpen pencircle scaled 2.78;
  endfor
  xdotlabel.lrt(btex $m_1$ etex, z[2]) withpen pencircle scaled 3.14;
  xdotlabel.top(btex $m$ etex, z[3]) withpen pencircle scaled 3.14;
  xdotlabel.llft(btex $m_2$ etex, z[4]) withpen pencircle scaled 3.14;
  xdotlabel.llft(btex $m_3$ etex, z[6]) withpen pencircle scaled 3.14;
  label.lrt(btex $\qquad \ldots$ etex, (x[7],2.2*dy)) withpen pencircle scaled 3.14;
  for i = 1,4,6:
    nczigzag(z[i])(z[i+1]) "arrows(-)", "coilwidth(1.1u)", "coilarmA(0)", "coilarmB(0)";
    %ObjLabel.Obj(p)(btex test etex)
  endfor
  drawarrow z[3]--z[2] withpen pencircle scaled 0.69 dashed evenly scaled 0.8;
  drawarrow z[3]--z[4] withpen pencircle scaled 0.69 dashed evenly scaled 0.8;
endfig;

end;
