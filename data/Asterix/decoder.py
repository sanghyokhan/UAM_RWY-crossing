import asterix
from pathlib import Path 
import csv


# directory
data_dir = Path('../MLAT_AST(191222-191228_KST)')
data_file = data_dir / 'tp1_20191221_150000_Cat20.ast'


f = open(data_file, 'rb' )
data = f.read()
parsed = asterix.parse_with_offset(data, offset=0, blocks_count=79)     # 파싱된 데이터는 딕셔너리 모양
formatted = asterix.describe(parsed)
print(formatted)





"""
# csv 저장
f = open(data_file, 'rb' )
data = f.read()
parsed = asterix.parse(data)     # 파싱된 데이터는 딕셔너리 모양
print(parsed)
for i in range(len(parsed)):
    with open('csv_test.csv', 'a') as save_data:  
        w = csv.DictWriter(save_data, parsed[i].keys())
        w.writeheader()
        w.writerow(parsed[i])
f.close()


# txt 저장
formatted = asterix.describe(parsed)
type(formatted)

text_file = open("text_test.txt", "w")
text_file.write(formatted)
text_file.close()
"""



"""

with open(data_file, "rb") as f:
    data = f.read()

    # Parse data description=True
    print('Items with description')
    print('----------------------')
    parsed = asterix.parse(data)
    for packet in parsed:
        for item in packet.items():
            print(item)

    print('Items without description')
    print('----------------------')
    # Parse data description=False
    parsed = asterix.parse(data, verbose=False)
    for packet in parsed:
        for item in packet.items():
            print(item)

    print('Textual description of data')
    print('----------------------')
    # describe Asterix data
    formatted = asterix.describe(parsed)
    print(formatted)
    
"""