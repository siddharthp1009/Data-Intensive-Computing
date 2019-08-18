#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# lets try making pair - mapper co occ

#!/usr/bin/env python
"""mapper.py"""

import sys

# input comes from STDIN (standard input)
coword = ["russian",    # only for testing
"security",
"state",
"united",
"cyber",
"campaign",
"government",
"company",
"election",
"official"]
for line in sys.stdin:
    line = line.strip()
    words = line.split()
    for word in range(0,len(words)):
        if (words[word] in coword and word+1 < len(words)):
            print '%s\t%s' % (words[word]+' '+words[word+1], 1)

