import os
import sys


def write_to_file(filename, variable):
    str = 'open("%s", write, Stream), ' % filename
    for var in variable:
        str += 'write(Stream, "%s = "), writeln(Stream, %s), ' % (var, var)
    str += 'close(Stream)'
    return str

def convert(tests, path):
    result_path = os.path.join(path, "results")
    if not os.path.exists(result_path):
        os.mkdir(result_path)
    commands = []
    for expr, var, name in tests:
        str = "swipl --stack_limit=4G -g 'consult(\"%s\").' " % os.path.join(path, "solution.pl")
        str = str + "-g '" + expr + ', ' + write_to_file(os.path.join(result_path, name), var) + ".' "
        str += "-g halt"
        commands.append(str)
    return commands

test_cases = [
    ("glanian_distance(galsab, foxfwit, Distance)", ["Distance"], "test-1-1.txt"),
    ("glanian_distance(thrgold_, talrem, Distance)", ["Distance"], "test-1-2.txt"),
    ("glanian_distance(floez, taeayld, Distance)", ["Distance"], "test-1-3.txt"),
    ("weighted_glanian_distance(malophe, onsap, Distance)", ["Distance"], "test-2-1.txt"),
    ("weighted_glanian_distance(eilialexa, ranau, Distance)", ["Distance"], "test-2-2.txt"),
    ("weighted_glanian_distance(zazmis, mysthae, Distance)", ["Distance"], "test-2-3.txt"),
    ("find_possible_cities(fabky, CityList)", ["CityList"], "test-3-1.txt"),
    ("find_possible_cities(taeori, CityList)", ["CityList"], "test-3-2.txt"),
    ("find_possible_cities(lavaow, CityList)", ["CityList"], "test-3-3.txt"),
    ("merge_possible_cities(lavito, thadark_, CityList)", ["CityList"], "test-4-1.txt"),
    ("merge_possible_cities(zynthmis, logno, CityList)", ["CityList"], "test-4-2.txt"),
    ("merge_possible_cities(dracmalu, sirshi, CityList)", ["CityList"], "test-4-3.txt"),
    ("find_mutual_activities(darabig, layquam, ActivityList)", ["ActivityList"], "test-5-1.txt"),
    ("find_mutual_activities(foxffun, sapcha, ActivityList)", ["ActivityList"], "test-5-2.txt"),
    ("find_mutual_activities(yvawispm, lili, ActivityList)", ["ActivityList"], "test-5-3.txt"),
    ("find_possible_targets(dagale, Distances, TargetList)", ["Distances", "TargetList"], "test-6-1.txt"),
    ("find_possible_targets(mortquam, Distances, TargetList)", ["Distances", "TargetList"], "test-6-2.txt"),
    ("find_possible_targets(thrlavi, Distances, TargetList)", ["Distances", "TargetList"], "test-6-3.txt"),
    ("find_weighted_targets(jewzapp, Distances, TargetList)", ["Distances", "TargetList"], "test-7-1.txt"),
    ("find_weighted_targets(balmerl, Distances, TargetList)", ["Distances", "TargetList"], "test-7-2.txt"),
    ("find_weighted_targets(ilyrmire, Distances, TargetList)", ["Distances", "TargetList"], "test-7-3.txt"),
    ("find_my_best_target(josizar, Distances, ActivityList, CityList, TargetList)", ["Distances", "ActivityList", "CityList", "TargetList"], "test-8-1.txt"),
    ("find_my_best_target(anthgall, Distances, ActivityList, CityList, TargetList)", ["Distances", "ActivityList", "CityList", "TargetList"], "test-8-2.txt"),
    ("find_my_best_target(jaylren, Distances, ActivityList, CityList, TargetList)", ["Distances", "ActivityList", "CityList", "TargetList"], "test-8-3.txt"),
    ("find_my_best_match(anthgall, Distances, ActivityList, CityList, TargetList)", ["Distances", "ActivityList", "CityList", "TargetList"], "test-9-1.txt"),
    ("find_my_best_match(nysow, Distances, ActivityList, CityList, TargetList)", ["Distances", "ActivityList", "CityList", "TargetList"], "test-9-2.txt"),
    ("find_my_best_match(gold_aid, Distances, ActivityList, CityList, TargetList)", ["Distances", "ActivityList", "CityList", "TargetList"], "test-9-3.txt"),
]

tests = convert(test_cases, sys.argv[1])
for test in tests:
    print(test)
    os.system(test)
