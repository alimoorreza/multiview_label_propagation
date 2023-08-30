
'''

Hi Yimeng,

I am a bit confused about the aggregated number of labels.

When I calculate the total number of labels from your constants.py file, I find a total of 1386, 
as follows:


len(ade20k_dict) + len(lvis_dict) + len(avd_dict) = 150 + 1203 + 33 = 1386.


However, in your semantic labeling files, I encounter labels such as 1502, 1503, and 1532. 
What are the additional labels? Or am I missing something?


Best regards,

-------------------------------------------------------------
Hi Reza,

Oh, this is my fault.
Here is the range of classes:

    0~150: ade20k
    151~1500: lvis
    1501~1533: avd instance

I set up the number 151 and 1500 because they are easier to remember.
So from labels 1354 to 1500, the labels are empty.

Thanks,
Yimeng

'''


import json
import scipy.io


# load ade20k categories
# starting offset: 0 (Reza: see Yimeng's comment at the top)
ade20k_dict = {
1: 'wall (ade20k)',
2: 'building (ade20k)',
3: 'sky (ade20k)',
4: 'floor (ade20k)',
5: 'tree (ade20k)',
6: 'ceiling (ade20k)',
7: 'road (ade20k)',
8: 'bed (ade20k)',
9: 'window (ade20k)',
10: 'grass (ade20k)',
11: 'cabinet (ade20k)',
12: 'sidewalk (ade20k)',
13: 'person (ade20k)',
14: 'earth (ade20k)',
15: 'door (ade20k)',
16: 'table (ade20k)',
17: 'mountain (ade20k)',
18: 'plant (ade20k)',
19: 'curtain (ade20k)',
20: 'chair (ade20k)',
21: 'car (ade20k)',
22: 'water (ade20k)',
23: 'painting (ade20k)',
24: 'sofa, couch (ade20k)',
25: 'shelf (ade20k)',
26: 'house (ade20k)',
27: 'sea (ade20k)',
28: 'mirror (ade20k)',
29: 'rug, carpet (ade20k)',
30: 'field (ade20k)',
31: 'armchair (ade20k)',
32: 'seat (ade20k)',
33: 'fence (ade20k)',
34: 'desk (ade20k)',
35: 'rock (ade20k)',
36: 'wardrobe (ade20k)',
37: 'lamp (ade20k)',
38: 'bathtub (ade20k)',    
39: 'railing (ade20k)',
40: 'cushion (ade20k)',
41: 'base, pedestal (ade20k)',
42: 'box (ade20k)',
43: 'column, pillar (ade20k)',
44: 'signboard (ade20k)',
45: 'dresser (ade20k)',
46: 'counter (ade20k)',
47: 'sand (ade20k)',
48: 'sink (ade20k)',
49: 'skyscraper (ade20k)',
50: 'fireplace (ade20k)',
51: 'refrigerator, icebox (ade20k)',
52: 'grandstand (ade20k)',
53: 'path (ade20k)',
54: 'stairs (ade20k)',
55: 'runway (ade20k)',
56: 'case (ade20k)',
57: 'pool table (ade20k)',
58: 'pillow (ade20k)',
59: 'screen door (ade20k)',
60: 'stairway (ade20k)',
61: 'river (ade20k)',
62: 'bridge (ade20k)',
63: 'bookcase (ade20k)',
64: 'blind (ade20k)',
65: 'coffee table (ade20k)',
66: 'toilet, potty (ade20k)',
67: 'flower (ade20k)',
68: 'book (ade20k)',
69: 'hill (ade20k)',
70: 'bench (ade20k)',
71: 'countertop (ade20k)',
72: 'stove (ade20k)',
73: 'palm (ade20k)',
74: 'kitchen island (ade20k)',
75: 'computer (ade20k)',
76: 'swivel chair (ade20k)',
77: 'boat (ade20k)',
78: 'bar (ade20k)',
79: 'arcade machine (ade20k)',
80: 'hovel (ade20k)',
81: 'bus (ade20k)',
82: 'towel (ade20k)',
83: 'light (ade20k)',
84: 'truck (ade20k)',
85: 'tower (ade20k)',
86: 'chandelier (ade20k)',
87: 'sunshade (ade20k)',
88: 'street lamp (ade20k)',
89: 'booth, cubicle (ade20k)',
90: 'television (ade20k)',
91: 'airplane (ade20k)',
92: 'dirt track (ade20k)',
93: 'clothes (ade20k)',
94: 'pole (ade20k)',
95: 'land, ground, soil (ade20k)',
96: 'bannister (ade20k)',
97: 'escalator (ade20k)',
98: 'ottoman (ade20k)',
99: 'bottle (ade20k)',
100: 'counter, sideboard (ade20k)',
101: 'poster (ade20k)',
102: 'stage (ade20k)',
103: 'van (ade20k)',
104: 'ship (ade20k)',
105: 'fountain (ade20k)',
106: 'conveyer belt (ade20k)',
107: 'canopy (ade20k)',
108: 'washing machine (ade20k)',
109: 'toy (ade20k)',
110: 'swimming pool (ade20k)',
111: 'stool (ade20k)',
112: 'barrel (ade20k)',
113: 'basket (ade20k)',
114: 'waterfall, falls',
115: 'tent (ade20k)',
116: 'bag (ade20k)',
117: 'motorbike (ade20k)',
118: 'cradle (ade20k)',
119: 'oven (ade20k)',
120: 'ball (ade20k)',
121: 'food (ade20k)',
122: 'step, stair (ade20k)',
123: 'tank, storage tank (ade20k)',
124: 'brand name (ade20k)',
125: 'microwave (ade20k)',
126: 'pot, flowerpot (ade20k)',
127: 'animal (ade20k)',
128: 'bicycle (ade20k)',
129: 'lake (ade20k)',
130: 'dishwasher (ade20k)',
131: 'screen, projection screen (ade20k)',
132: 'blanket, cover (ade20k)',
133: 'sculpture (ade20k)',
134: 'exhaust hood (ade20k)',
135: 'sconce (ade20k)',
136: 'vase (ade20k)',
137: 'traffic signal (ade20k)',
138: 'tray (ade20k)',
139: 'trash can, garbage can (ade20k)',
140: 'fan (ade20k)',
141: 'pier, wharf (ade20k)',
142: 'crt screen (ade20k)',
143: 'plate (ade20k)',
144: 'monitor (ade20k)',
145: 'bulletin board (ade20k)',
146: 'shower (ade20k)',
147: 'radiator (ade20k)',
148: 'glass (ade20k)',
149: 'clock (ade20k)',
150: 'flag (ade20k)'
}

json_file_path = "json_files/ade20k_categories_clean.json"
with open(json_file_path, 'w') as json_file:
    json.dump(ade20k_dict, json_file)


# load lvis categories
# starting offset: len(ade20k_dict) = 150 (Reza: see Yimeng's comment at the top)
start_offset = len(ade20k_dict)
f = open(f'json_files/lvis_categories.json', "r")
data = json.loads(f.read())
lvis_dict = {}
for idx in range(len(data)):
    cat_id = data[idx]['id'] + start_offset
    cat_name = data[idx]['name']
    lvis_dict[cat_id] = cat_name + ' (lvis)'

json_file_path = f"json_files/lvis_categories_clean.json"
with open(json_file_path, 'w') as json_file:
    json.dump(lvis_dict, json_file)



# load avd
# starting offset: len(ade20k_dict) = 150 (Reza: see Yimeng's comment at the top)
start_offset = 1500
f = open(f"json_files/avd_instance_label_map.json", "r")
data = json.loads(f.read())
avd_dict = {}
for k in list(data.keys()):
    k_int = int(k) + start_offset
    if k_int > 0:
        avd_dict[k_int] = data[k] + ' (avd)'

json_file_path = f"json_files/avd_categories_clean.json"
with open(json_file_path, 'w') as json_file:
    json.dump(avd_dict, json_file)


