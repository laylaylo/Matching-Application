import os
import sys

def read_dic(path):
    results = os.listdir(path)
    dic = {}
    for test in results:
        f = open(os.path.join(path, test), "r")
        lines = f.readlines()
        f.close()
        dic[test] = lines
    return dic

def transform_dic(dic):
    tr_dic = dic.copy()
    keys = list(dic.keys())
    set_1 = []
    for i in range(1, 3):
        for j in range(1, 4):
            set_1.append("test-{}-{}.txt".format(i, j))
    set_2 = []
    for i in range(3, 6):
        for j in range(1, 4):
            set_2.append("test-{}-{}.txt".format(i, j))
    set_3 = []
    for i in range(6, 10):
        for j in range(1, 4):
            set_3.append("test-{}-{}.txt".format(i, j))

    for case in set_1:
        if case in keys:
            tr_dic[case] = float(tr_dic[case][0].split()[-1])

    for case in set_2:
        if case in keys:
            tr_dic[case] = sorted(set(tr_dic[case][0].split()[-1][1:-1].split(",")))

    for case in set_3:
        if case in keys:
            fields = [field.split()[-1][1:-1].split(",") for field in tr_dic[case]]
            concatenated = []
            for values in zip(*fields):
                values = (values[0][:10],) + values[1:]
                concatenated.append("".join(values))
            tr_dic[case] = sorted(set(concatenated))
    return tr_dic

def check(truth, query):
    result = {}
    query_keys = query.keys()
    for key in truth:
        a = truth[key]
        if key in query_keys:
            b = query[key]
            if type(a) == list:
                result[key] = (a==b)
            elif type(a) == float:
                result[key] = (abs(a-b) < 1e-8)
        else:
            result[key] = False
    for key in sorted(result):
        print(f"{key}: {result[key]}")


if __name__ == "__main__":
    check(transform_dic(read_dic(sys.argv[1])), transform_dic(read_dic(sys.argv[2])))
