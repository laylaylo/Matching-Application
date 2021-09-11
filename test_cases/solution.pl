% leyla yayladere
% 2018400216
% compiling: yes
% complete: yes

:- encoding(utf8).
% include the knowledge base
:- ['load.pro'].

% 3.1 glanian_distance(Name1, Name2, Distance) 5 points >> done

glanian_distance(Name1, Name2, Distance) :- 
	expects(Name1, _ , ExpectedList),
	glanian(Name2, _, FeatureList),
	calculate_distance(ExpectedList, FeatureList, D),
	Distance is D^0.5.

calculate_distance([],[],0).
calculate_distance(List1, List2 , Distance) :-
	[Head1|Tail1] = List1,
	[Head2|Tail2] = List2,
	calculate_distance(Tail1, Tail2, TailDistance),
	(Head1 = -1 -> Distance is TailDistance ; Distance is (Head1 - Head2)^2 + TailDistance).


% 3.2 weighted_glanian_distance(Name1, Name2, Distance) 10 points >> done

weighted_glanian_distance(Name1, Name2, Distance) :-
	expects(Name1, _, ExpectedList),
	weight(Name1, WeightList),
	glanian(Name2, _, FeatureList),
	calculate_weighted_distance(ExpectedList, FeatureList, WeightList, D),
	Distance is D^0.5.

calculate_weighted_distance([], [], [], 0).
calculate_weighted_distance(List1, List2, ListW, Distance) :-
	[Head1|Tail1] = List1,
	[Head2|Tail2] = List2,
	[HeadW|TailW] = ListW,
	calculate_weighted_distance(Tail1, Tail2, TailW, TailDistance),
	(Head1 = -1 -> Distance is TailDistance ; Distance is HeadW * (Head1 - Head2)^2 + TailDistance).


% 3.3 find_possible_cities(Name, CityList) 5 points >> done

find_possible_cities(Name, CityList) :-
	city(CurrentCity, HabitantList,_),
	member(Name, HabitantList),
	likes(Name, _, LikedCities),
	[CurrentCity|LikedCities] = CityList.


% 3.4 merge_possible_cities(Name1, Name2, MergedCities) 5 points >> done

merge_possible_cities(Name1, Name2, MergedCities) :-
	find_possible_cities(Name1, CityList1),
	find_possible_cities(Name2, CityList2),
	union(CityList1, CityList2, MergedCities).

union(L, [], L).
union(List1, List2, MergedList) :-
	[Head|Tail] = List2,
	(member(Head, List1) -> union(List1, Tail, MergedList) ; append(List1, [Head], NewList) , union(NewList, Tail, MergedList)).


% 3.5 find_mutual_activities(Name1, Name2, MutualActivities) 5 points >> done 

find_mutual_activities(Name1, Name2, MutualActivities) :-
	likes(Name1, LikedActivities1, _),
	likes(Name2, LikedActivities2, _),
	intersection(LikedActivities1, LikedActivities2, MutualActivities).

intersection([], _, []).
intersection(List1, List2, Mutual) :-
	[Head|Tail] = List1,
	intersection(Tail, List2, TailMutual),
	(member(Head, List2) -> Mutual = [Head|TailMutual] ; Mutual = TailMutual).


% 3.6 find_possible_targets(Name, TargetList) 10 points >> done

find_possible_targets(Name, Distances, TargetList) :-   
	expects(Name, ExpectedGenders, _),
	find_targets(ExpectedGenders, Targets_),
	delete(Targets_, Name, Targets),
	distances_name_pairs(Name, Targets, Pairs),
	keysort(Pairs, SortedPairs),
	split_pairs(SortedPairs, Distances, TargetList).

find_targets([], []).
find_targets(ExpectedGenders, Targets) :-
	[Head|Tail] = ExpectedGenders,
	find_targets(Tail, TargetsTail),
	findall(TargetName, glanian(TargetName, Head,_), TargetsHead),
	union(TargetsHead, TargetsTail, Targets).

distances_name_pairs(_, [], []).
distances_name_pairs(Name, Targets, Pairs) :-
	[Head|Tail] = Targets,
	distances_name_pairs(Name, Tail, DistanceTail),
	glanian_distance(Name, Head, D),
	Pairs = [D-Head|DistanceTail].

split_pairs([],[],[]).
split_pairs(SortedPairs, SortedList1, SortedList2) :-
	[Head|Tail] = SortedPairs,
	Head = List1-List2,
	split_pairs(Tail, List1Tail, List2Tail),
	SortedList1 = [List1|List1Tail],
	SortedList2 = [List2|List2Tail].

% 3.7 find_weighted_targets(Name, Distances, TargetList) 15 points >> done

find_weighted_targets(Name, Distances, TargetList) :-
	expects(Name, ExpectedGenders, _),
	find_targets(ExpectedGenders, Targets_),
	delete(Targets_, Name, Targets),
	weighted_name_pairs(Name, Targets, Pairs),
	keysort(Pairs, SortedPairs),
	split_pairs(SortedPairs, Distances, TargetList).

weighted_name_pairs(_ ,[] ,[]).
weighted_name_pairs(Name, Targets, Pairs) :-
	[Head|Tail] = Targets,
	weighted_name_pairs(Name, Tail, WeightedTail),
	weighted_glanian_distance(Name, Head, W),
	Pairs = [W-Head|WeightedTail].


% 3.8 find_my_best_target(Name, Distances, Activities, Cities, Targets) 20 points >> done

find_my_best_target(Name, Distances, Activities, Cities, Targets) :-
	find_weighted_targets(Name, _, PossibleTargets),
	detect_old_relation(Name, PossibleTargets, NewTargets),
	detect_limits(Name, NewTargets, LimitedTargets),
	detect_target(Name, LimitedTargets, TargetList1),
	helper_city(Name, TargetList1, CityList, TargetList2),
	helper_activity(Name, CityList, TargetList2, Distances, Activities, Cities, Targets).

helper_city(_, [], [], []).
helper_city(Name, TargetList, Cities, Targets) :-
	[Head|Tail] = TargetList,
	helper_city(Name, Tail, CityTail, TargetTail),
	merge_possible_cities(Name, Head, MergedCities),
	detect_city(Name, MergedCities, CityHead),
	length(CityHead, Length),
	copier(Head, Length, TargetHead),
	append(CityHead, CityTail, Cities),
	append(TargetHead, TargetTail, Targets).

helper_activity(_, [], [], [], [], [], []).
helper_activity(Name,CityList, TargetList, Distances, Activities, Cities, Targets) :-
	[Head1|Tail1] = CityList,
	[Head2|Tail2] = TargetList,
	helper_activity(Name, Tail1, Tail2, DistanceTail, ActivityTail, CityTail, TargetTail),
	find_possible_cities(Name, NameCityList),
	(member(Head1, NameCityList) -> city(Head1, _, ActivityList),
	detect_dislike_activity(Name, ActivityList, ActivityHead) ; city(Head1, _, ActivityList),
	detect_like_activity(Name, ActivityList, ActivityHead)),
	weighted_glanian_distance(Name, Head2, D),
	length(ActivityHead, Length),
	copier(D, Length, DistanceHead),
	copier(Head1, Length, CityHead),
	copier(Head2, Length, TargetHead),
	append(DistanceHead, DistanceTail, Distances),
	append(ActivityHead, ActivityTail, Activities),
	append(CityHead, CityTail, Cities),
	append(TargetHead, TargetTail, Targets).
	
copier(Target, Length, TargetList) :-
	length(TargetList, Length),
	maplist(=(Target), TargetList).

detect_old_relation(_, [], []).
detect_old_relation(Name, TargetList, NewTargets) :-
	[Head|Tail] = TargetList,
	detect_old_relation(Name, Tail, TargetTail),
	List = [Name|Head],
	Reverse = [Head|Name],
	(old_relation(List) -> NewTargets =  TargetTail; (old_relation(Reverse) -> NewTargets = TargetTail ; NewTargets = [Head|TargetTail])).

detect_limits(_, [], []).
detect_limits(Name, TargetList, LimitedTarget) :-
	[Head|Tail] = TargetList,
	detect_limits(Name, Tail, LimitedTail),
	glanian(Head, _, Features),
	dislikes(Name, _, _, Limits),
	suitable(Limits, Features, Result),
	(empty_list(Result) -> LimitedTarget = [Head|LimitedTail]; LimitedTarget = LimitedTail).

suitable([], [], []).
suitable(Limits, Features, Result) :-
	[Head|Tail] = Features,
	[Head1|Tail1] = Limits,
	suitable(Tail1, Tail, ResultTail),
	(empty_list(Head1) -> Result = ResultTail;
	[Min|[Max]] = Head1,
	(in_range(Head, Min, Max) -> Result = ResultTail ; Result = [Head|ResultTail])).

detect_target(_, [], []).
detect_target(Name, TargetList, Result) :-
	[Head|Tail] = TargetList,
	detect_target(Name, Tail, ResultTail),
	dislikes(Name, DislikedActivities, _, _),
	likes(Head, LikedActivities, _),
	intersection(DislikedActivities, LikedActivities, Intersection),
	length(Intersection, Length),
	(Length > 2 -> Result = ResultTail ; Result = [Head|ResultTail]).

empty_list(List) :- not(member(_, List)).

in_range(X, Min, Max):- X > Min, X < Max.

detect_city(_, [], []).
detect_city(Name, CityList, Result) :-
	[Head|Tail] = CityList,
	detect_city(Name, Tail, ResultTail),
	dislikes(Name, _, DislikedCities, _),
	city(Head, Habitants, Activities),
	likes(Name, LikedActivities, LikedCities),
	intersection(Activities, LikedActivities, Intersection),
	length(Intersection, Length),
	(member(Head,LikedCities) -> Result = [Head|ResultTail] ; (member(Head, DislikedCities) -> Result = ResultTail ; (member(Name, Habitants) -> Result = [Head|ResultTail] ; (Length > 0 -> Result = [Head|ResultTail] ; Result = ResultTail)))).

detect_dislike_activity(_, [], []).
detect_dislike_activity(Name, ActivityList, Result) :-
	[Head|Tail] = ActivityList,
	detect_dislike_activity(Name, Tail, ResultTail),
	dislikes(Name, DislikedActivities, _, _),
	(member(Head, DislikedActivities) -> Result = ResultTail ; Result = [Head|ResultTail]).

detect_like_activity(_, [], []).
detect_like_activity(Name, ActivityList, Result) :-
	[Head|Tail] = ActivityList,
	detect_like_activity(Name, Tail, ResultTail),
	likes(Name, LikedActivities, _
	),
	(member(Head, LikedActivities) -> Result = [Head|ResultTail] ; Result = ResultTail).

% 3.9 find_my_best_match(Name, Distances, Activities, Cities, Targets) 25 >> done but get different results and sort is wrong;

find_my_best_match(Name, Distances, Activities, Cities, Targets) :-
	find_weighted_targets(Name, _, PossibleTargets),
	detect_old_relation(Name, PossibleTargets, NewTargets),
	detect_limits(Name, NewTargets, LimitedTargets),
	detect_target(Name, LimitedTargets, BestTargets),
	detect_match(Name, BestTargets, MatchedTargets),
	city_helper(Name, MatchedTargets, CityList, TargetList),
	activity_helper(Name, CityList, TargetList, Distances, Activities, Cities, Targets).

detect_match(_, [], []).
detect_match(Name, BestTargets, MatchedTargets) :-
	[Head|Tail] = BestTargets,
	detect_match(Name, Tail, MatchedTail),
	detect_limits(Head, [Name], Result1),
	detect_target(Head, [Name], Result2),
	expects(Head, ExpectedGenders, _),
	glanian(Name, Gender, _),
	(empty_list(Result1) -> MatchedTargets = MatchedTail ; (empty_list(Result2) -> MatchedTargets = MatchedTail ; (member(Gender, ExpectedGenders) -> MatchedTargets = [Head|MatchedTail] ; MatchedTargets = MatchedTail))).


city_helper(_, [], [], []).
city_helper(Name, MatchedTargets, Cities, Targets) :-
	[Head|Tail] = MatchedTargets,
	city_helper(Name, Tail, CityTail, TargetTail),
	merge_possible_cities(Name, Head, MergedCities),
	detect_city(Name, MergedCities, CityList1),
	detect_city(Head, MergedCities, CityList2),
	intersection(CityList1, CityList2, CityHead),
	length(CityHead, Length),
	copier(Head, Length, TargetHead),
	append(CityHead, CityTail, Cities),
	append(TargetHead, TargetTail, Targets).

activity_helper(_, [], [], [], [], [], []).
activity_helper(Name, CityList, TargetList, Distances, Activities, Cities, Targets) :-
	[Head1|Tail1] = CityList,
	[Head2|Tail2] = TargetList,
	activity_helper(Name, Tail1, Tail2, DistanceTail, ActivityTail, CityTail, TargetTail),
	find_possible_cities(Name, NameCityList),
	(member(Head1, NameCityList) -> city(Head1, _, ActivityList1),
	detect_dislike_activity(Name, ActivityList1, ActivityHead1) ; city(Head1, _, ActivityList1),
	detect_like_activity(Name, ActivityList1, ActivityHead1)),
	find_possible_cities(Head2, TargetCityList),
	(member(Head1, TargetCityList) -> city(Head1, _, ActivityList2),
	detect_dislike_activity(Head2, ActivityList2, ActivityHead2) ; city(Head1, _, ActivityList2),
	detect_like_activity(Head2, ActivityList2, ActivityHead2)),
	intersection(ActivityHead1, ActivityHead2, ActivityHead),
	weighted_glanian_distance(Name, Head2, D1),
	weighted_glanian_distance(Head2, Name, D2),
	D is (D1+D2)/2,
	length(ActivityHead, Length),
	copier(D, Length, DistanceHead),
	copier(Head1, Length, CityHead),
	copier(Head2, Length, TargetHead),
	append(DistanceHead, DistanceTail, Distances),
	append(ActivityHead, ActivityTail, Activities),
	append(CityHead, CityTail, Cities),
	append(TargetHead, TargetTail, Targets).
