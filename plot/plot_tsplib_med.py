#!/usr/bin/python
#
# $Id$
# $Author$
# $Date$
# $Rev: 34 $
#

import sys
import seaborn as sns
import pandas as pd

data = [
  ["pyr. (flower)", "data/tsplib_med_val_pyramidal_mdef_i0_jdef_rall_adef_fdef.csv"],
  ["s.b. (M=2,flower)", "data/tsplib_med_val_balanced_m2_i0_jdef_rall_adef_fdef.csv"],
  ["s.b. (M=3,flower)", "data/tsplib_med_val_balanced_m3_i0_jdef_rall_adef_fdef.csv"],
]
frame = pd.DataFrame()
for d in data:
  frame[d[0]] = pd.read_csv(d[1], sep=" ", header=None, names=["inst", "val"], usecols = ["val"])

color = '#000000'
format = 'pdf'
if sys.argv[1] == "eps":
  color = '#796045'
  format = 'eps'
sns.set(font_scale=1.41)
sns.set_style("whitegrid",rc={
  "grid.color": color,
  "xtick.color": color,
  "ytick.color": color,
  "axes.edgecolor": color,
  "axes.labelcolor": color,
  "text.facecolor": 'white',
  })
sns.set_palette("Set1",desat=0.22)
sns.axlabel("tour quality", "") #"heuristic")
ax = sns.boxplot(frame, orient="h")
ax.get_figure().subplots_adjust(left=0.24)
ax.get_figure().savefig('build/tsplib_med_val.' + format, format=format, transparent=True)
