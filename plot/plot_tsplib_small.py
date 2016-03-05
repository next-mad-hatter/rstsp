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
  ["pyr. adaptive", "data/tsplib_small_val_pyramidal_mdef_i0_jdef_rall_a2_fdef.csv"],
  ["pyr. rotated", "data/tsplib_small_val_pyramidal_mdef_i0_jdef_rall_adef_fdef.csv"],
  ["s.b. (M=3) adaptive", "data/tsplib_small_val_balanced_m3_i0_jdef_rall_a2_fdef.csv"],
  ["s.b. (M=3) rotated", "data/tsplib_small_val_balanced_m3_i0_jdef_rall_adef_fdef.csv"],
  ["flipflop", "data/tsplib_small_val_balanced_m3_i0_jdef_rall_a2_f0.csv"],
  ["s.b. (M=4) rotated", "data/tsplib_add_val_balanced_m4_i0_jdef_rall_adef_fdef.csv"],
]
frame = pd.DataFrame()
for d in data:
  frame[d[0]] = pd.read_csv(d[1], sep=" ", header=None, names=["inst", "val"], usecols = ["val"], na_values=["t"])

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
ax.get_figure().savefig('build/tsplib_small_val.' + format, format=format, transparent=True)
