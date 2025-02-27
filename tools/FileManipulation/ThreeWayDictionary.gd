class_name ThreeWayDictionary extends Node

var _three_way_dict = {}

func set_index_index_data(first, second, data):
	if not _three_way_dict.has(first):
		_three_way_dict[first] = {}
	_three_way_dict[first][second] = data

## get data under 2 indexes
func get_index_index_data(first, second):
	if _three_way_dict.has(first):
		if _three_way_dict[first].has(second):
			return _three_way_dict[first][second]
	return

## get values under index if count is 1
func get_first_range(start_at, count):
	return _three_way_dict.values().slice(start_at, start_at + count)

## get values under index if count is 1
func get_second_range(first, start_at, count):
	if _three_way_dict.has(first):
		return _three_way_dict[first].values().slice(start_at, start_at + count)
	return

## first dictionary count
func get_count_first():
	return len(_three_way_dict)

## second dictionary count if first index is correct
func get_count_second(first):
	if _three_way_dict.has(first):
		return len(_three_way_dict[first])
	return 0


	#///<summary>set data if it already exists we rewrite it</summary>
	#public void Set(TFt firstT, TSt secondT, TDataT dataT){
		#try{
			#if(! _threeWayDict.ContainsKey(firstT)){
				#_threeWayDict.Add(firstT, new Dictionary<TSt, TDataT>());
			#}
			#if(! _threeWayDict[firstT].ContainsKey(secondT)){
				#_threeWayDict[firstT].Add(secondT, dataT);
			#}
			#//we rewrite the data
			#else{
				#_threeWayDict[firstT][secondT] = dataT;
			#}
		#}
		#catch (System.Exception e){
			#Debug.LogError(e);
		#}

#public class ThreeWayDictionary<TFt, TSt, TDataT> {
	#private readonly Dictionary<TFt, Dictionary<TSt, TDataT>> _threeWayDict = new Dictionary<TFt, Dictionary<TSt, TDataT>>();

	#/// <summary>
	#/// if index is 0 we return secondT else element at dict
	#/// </summary>
	#public TDataT Get(TFt firstT, TSt secondT, int index){
		#try{
			#if(! _threeWayDict.ContainsKey(firstT)){
				#Debug.LogError($"firstT {firstT.ToString()} doesn't exists");
				#return default(TDataT);
			#}
			#//we search under secondT key
			#if(index < 0){
				#if(! _threeWayDict[firstT].ContainsKey(secondT)){
					#Debug.LogError($"firstT {firstT.ToString()} exists secondT {secondT.ToString()} doesn't exist");
					#return default(TDataT);
				#}
				#//we return data
				#return _threeWayDict[firstT][secondT];
			#}
			#//we search under element
			#else{
				#if(_threeWayDict[firstT].Count < index){
					#Debug.LogError($"firstT {firstT.ToString()} exists index is too big {index} count: {_threeWayDict[firstT].Count}");
					#return default(TDataT);
				#}
				#return _threeWayDict[firstT].Values.ElementAt(index);
			#}
		#}
		#catch{
			#Debug.LogError("it's null doesn't exist or?");
			#return default(TDataT);
		#}

	#///<summary>get FT from startAt + count</summary>
	#public TFt[] Get(int startAt, int count){
		#try{
			#int thisCount = GetCountFirstT();
			#//we make count how much does it still have only if count is smaller than it actually could be
			#if(thisCount < startAt + count){
				#//5         2       10
				#count = thisCount - startAt;
			#}
			#if(count < 0){
				#return null;
			#}
			#//we check index by index
			#TFt[] data = new TFt[count];
			#for (int i = 0; i < count; i++){
				#data[i] = GetFirstT(startAt + i);
			#}
			#//if it has gone through only here we return the value
			#return data;
		#}
		#catch (System.Exception e){
			#Debug.LogError(e);
			#return null;
		#}

	#///<summary>get ST from FT => startAt + count</summary>
	#public TDataT[] Get(TFt firstT, int startAt, int count){
		#try{
			#int thisCount = GetCountSecondT(firstT);
			#//we make count how much does it still have only if count is smaller than it actually could be
			#if(thisCount < startAt + count){
				#//5         2       10
				#count = thisCount - startAt;
			#}
			#if(count < 0){
				#return null;
			#}
			#//we check index by index
			#TDataT[] data = new TDataT[count];
			#for (int i = 0; i < count; i++){
				#data[i] = Get(firstT, default(TSt),startAt + i);
			#}
			#//if it has gone through only here we return the value
			#return data;
		#}
		#catch (System.Exception e){
			#Debug.LogError(e);
			#throw;
			#//return null;
		#}



	#///<summary>get FT at index</summary>
	#public TFt GetFirstT(int index){
		#try{
			#Debug.LogWarning(index);
			#if(_threeWayDict.Count <= index){
				#Debug.LogError($"index {index} is too big: {_threeWayDict.Count}");
				#return default(TFt);
			#}
			#Debug.LogWarning("through " + index);
			#return _threeWayDict.Keys.ElementAt(index);
		#}
		#catch (System.Exception e){
			#Debug.LogError(e);
			#return default(TFt);
		#}

	#///<summary>get ST at FT => index</summary>
	#public TSt GetSecondT(TFt firstT, int index){
		#try{
			#if(! _threeWayDict.ContainsKey(firstT)){
				#Debug.LogError($"firstT {firstT.ToString()} doesn't exists");
				#return default(TSt);
			#}
			#if(_threeWayDict[firstT].Count <= index){
				#Debug.LogError($"index {index} is too big: {_threeWayDict[firstT].Count}");
				#return default(TSt);
			#}
			#return _threeWayDict[firstT].Keys.ElementAt(index);
		#}
		#catch (System.Exception e){
			#Debug.LogError(e);
			#return default(TSt);
		#}

	#///<summary>count FT</summary>
	#public int GetCountFirstT() => _threeWayDict.Count;
	#///<summary>count ST at FT</summary>
	#public int GetCountSecondT(TFt firstT){
		#try{
			#if(! _threeWayDict.ContainsKey(firstT)){
				#Debug.LogError($"firstT {firstT.ToString()} doesn't exists");
				#return 0;
			#}
			#return _threeWayDict[firstT].Count;
		#}
		#catch (System.Exception e){
			#Debug.LogError($"firstT {firstT.ToString()} doesn't exists");
			#Debug.LogError(e);
			#throw;
			#//return 0;
		#}
	#}
#}
