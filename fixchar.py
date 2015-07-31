#!/usr/bin/python
# Copyright 2015 Open Connectome Project (http://openconnecto.me)
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
This script removes characters from reconstruct files that are incompatible with the Linux or Mac OS X operating system. 
"""

import sys
import os
from os.path import isfile, join 
from xml.etree.ElementTree import parse

path = '' # full path to file 
filename_to_test = '' # 
# get all files in this dir 
files = [ f for f in os.listdir(path) if isfile(join(path,f)) ]

# iterate over files, if filename starts with R34js-gs import as xml
for f in files:
    [filename, extension] = f.split('.', 1)
    if filename == filename_to_test:
        print "Parsing file: " + f
        parse(f)
