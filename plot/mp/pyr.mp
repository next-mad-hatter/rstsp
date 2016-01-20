%
% $Author$
% $File$
% $Date$
% $Revision$
%

input cmarrows
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
  u = 2.71mm;
  %796045
  drawoptions(withcolor (121/255,96/255,69/255));
  interim ahlength := 7bp;
  interim ahangle := 30;
  pair p[];
  p1 = (0,0); p2 = (10u,0); p3 = (20u,0); p4 = (30u,0); p5 = (40u,0);
  pair c[];
  c1 = (5u,2u); c2 = (21u,3u); c3 = (25u,-1u); c4 = (10u,-2u);
  path a;
  a = p1 .. controls c1 ..
      p2 .. controls c2 ..
      p4 ..
      p5 .. controls c3 ..
      p3 ..  controls c4 ..
      cycle ;
  for i = 1 upto length a:
    xdotlabel.top(decimal i, p[i]) withpen pencircle scaled 3.14;
    drawarrow subpath (i-1,i) of a withpen pencircle scaled 0.69; % withcolor 0.2;
  endfor
endfig;

beginfig(2)
  numeric u;
  u = 1.69mm;
  %796045
  drawoptions(withcolor (121/255,96/255,69/255));
  z1 = (0,3u); z2 = (8u,6u); z3 = (16u,12u); z4 = (24u,15u); z5 = (32u,9u); z6 = (40u,3u);
  for i = 1 upto 6:
    xdotlabel.top(decimal(y[i]/3u), z[i]) withpen pencircle scaled 3.14;
    %draw (x[i],y[1])--(x[i],y[1]+0.3u) withpen pencircle scaled 0.20;
    draw (x[i],y[1]) withpen pencircle scaled 0.70;
  endfor
  for i = 1 upto 5:
    draw z[i]--z[i+1] withpen pencircle scaled 0.69;
  endfor
endfig;

beginfig(3)
  numeric u;
  u = 1.69mm;
  dx = 6u;
  dy = 1.7u;
  %796045
  drawoptions(withcolor (121/255,96/255,69/255));
  for i = 0 upto 7:
    z[i] = (i * dx, i * dy);
  endfor
  y[2] := 3*dy;
  y[3] := 5*dy;
  y[4] := 8.2*dy;
  y[5] := 5*dy;
  y[6] := 2*dy;
  y[7] := 0*dy;
  z[8] = (4*dx,3.5*dy);
  string l[];
  l[0] = "1";
  l[1] = "2";
  l[2] = "4";
  l[3] = "";
  l[4] = "";
  l[5] = "";
  l[6] = "3";
  l[7] = "1";
  l[8] = "5";
  for i = 0,1,2,4,6,7,8:
    draw (x[i],y[i]) withpen pencircle scaled 0.70;
    xdotlabel.top(l[i], z[i]) withpen pencircle scaled 3.14;
  endfor
  xdotlabel.top(btex $n$ etex, z[4]) withpen pencircle scaled 3.14;
  for i = 0,1,6:
    draw z[i]--z[i+1] withpen pencircle scaled 0.69;
  endfor
  for i = 2,6:
    draw z[i]--z[4] withpen pencircle scaled 0.69 dashed withdots scaled 1.2;
    draw z[i]--z[4] withpen pencircle scaled 0.69 dashed withdots scaled 1.2;
  endfor
  drawarrow z[8]--(1/3[z[2],z[4]]) withpen pencircle scaled 0.69 dashed evenly scaled 0.8;
  drawarrow z[8]--(1/3[z[6],z[4]]) withpen pencircle scaled 0.69 dashed evenly scaled 0.8;
endfig;

end;
