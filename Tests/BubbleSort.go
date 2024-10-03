func bubbleSort(arr []int, n int) {
	var i int;
	var j int;
	var t1 int;

	t1 = n - 1 ;
	i = 0;

	for i < t1{
		var t2 int;
		t2 = n-i-1;
		j = 0;
		for j < t2 {
			var nextPos int;
			nextPos = j + 1;
			var current int;
			current = arr[j];
			var next int;
			next = arr[nextPos];
			if current > next {
				arr[j] = next;
				arr[nextPos] = current;
			};
			j = j + 1;
			};
			i = i + 1;
		};
	}

	func main() {
		var arr []int;
		var length int;
		var i int;
		var n int;
		var val int;
		fmt.Println("Insert the number of values:");
		fmt.Scanln(&length);
		arr = make([]int, length);
		i = 0 ;
		fmt.Println("Insert the values:");
		for i < length{
			var l int;
        	fmt.Scanln(&l);
			arr[i] = l;
			i = i + 1;
    	};
		n = len(arr);
		i = 0;
		fmt.Println("Unsorted array:");
		for i < n {
			val = arr[i];
			fmt.Print(val);
			fmt.Print(" ");
			i = i + 1;
		};
		fmt.Println("");
		bubbleSort(arr, n);
		fmt.Println("Sorted array:");
		i = 0;
		for i < n {
			val = arr[i];
			fmt.Print(val);
			fmt.Print(" ");
			i = i + 1;
		};
		fmt.Println("");
	}