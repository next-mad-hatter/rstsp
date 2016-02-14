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
  ["pyr. (adaptive)", "data/tsplib_small_time_pyramidal_mdef_i0_jdef_rall_a2_fdef.csv"],
  ["pyr. (flower)", "data/tsplib_small_time_pyramidal_mdef_i0_jdef_rall_adef_fdef.csv"],
  ["s.b. (M=3,adaptive)", "data/tsplib_small_time_balanced_m3_i0_jdef_rall_a2_fdef.csv"],
  ["s.b. (M=3,flower)", "data/tsplib_small_time_balanced_m3_i0_jdef_rall_adef_fdef.csv"],
  ["flipflop (r=8)", "data/tsplib_small_time_balanced_m3_i0_jdef_r8_a2_f0.csv"],
  ["flipflop", "data/tsplib_small_time_balanced_m3_i0_jdef_rall_a2_f0.csv"],
]
frame = pd.DataFrame()
for d in data:
  frame[d[0]] = pd.read_csv(d[1], sep=" ", header=None, names=["inst", "time"], usecols = ["time"])

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
sns.axlabel("time needed", "") #"heuristic")
ax = sns.boxplot(frame, orient="h")
ax.get_figure().subplots_adjust(left=0.24)
ax.set(xscale="log")
ax.get_figure().savefig('build/tsplib_time.' + format, format=format, transparent=True)
