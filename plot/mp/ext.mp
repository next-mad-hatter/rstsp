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
  interim ahlength := 3bp;
  interim ahangle := 50;
  if outputformat = "eps":
    %796045
    drawoptions(withcolor (121/255,96/255,69/255));
  else:
    outputformat := "eps";
  fi;

  numeric u;
  u = 2.69mm;
  dx = 5u;
  dy = 1.4u;

  z[1] = (dx,dy);
  z[2] = (5*dx,2*dy);

  numeric r;
  r = 2dx;
  xdotlabel.llft(btex $\tau$ etex, z[1]) withpen pencircle scaled 3.14;
  xdotlabel.llft(btex $\tau^\ast$ etex, z[2]) withpen pencircle scaled 3.14;
  draw fullcircle scaled r shifted z[1] dashed withdots scaled 0.4;
  draw fullcircle scaled r shifted z[2];

  r := 0.25r;
  pair t[];
  t[1] = (0.45r,-0.98r);
  t[2] = (-0.79r,0.69r);
  t[3] = (0.86r,0.87r);

  for i = 1 upto 2:
    for j = 1 upto 3:
      draw z[i]+t[j] withpen pencircle scaled 2.69;
      %fill z[i]+t[j] withcolor transparent(1,0,white) scaled 2.50;
      drawarrow z[i]--(z[i]+t[j]) withpen pencircle scaled 0.49 dashed evenly scaled 0.6;
    endfor
  endfor

  interim ahlength := 5bp;
  interim ahangle := 50;
  drawarrow (z[2]-(0.6u,0.96u))
      .. (1/3[x[2],x[1]],-dy)
      .. (2/3[x[2],x[1]],-dy)
      .. (z[1]+(0.4u,-0.2u)) withpen pencircle scaled 0.89;

  label.llft(btex $T$ etex, z[2]-(0.9dx,-2.75dy));
  label.llft(btex $F_T(\tau)$ etex, z[1]+(1.6dx,3.14dy));

endfig;

end;
