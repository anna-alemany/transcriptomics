import sys, os
import pandas as pd
import numpy as np

try:
  inputfile = sys.argv[1]
except:
  sys.exit("Please, give input file with count table")
  
