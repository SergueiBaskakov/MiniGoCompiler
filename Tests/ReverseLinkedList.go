type Node struct {
	value int;
	next  *Node;
}

type LinkedList struct {
	head *Node;
}

func Append(list *LinkedList, value int) {
    var newNode *Node;
	
	newNode = &Node{value: value};
	
	var tempHead *Node;
	
	tempHead = list.head;

	if tempHead == nil {
		list.head = newNode;
	} else {
		var current *Node;
		var next *Node;
		current = list.head;
		next = current.next;

		for next != nil {
			current = next;
			next = current.next;
		};

		current.next = newNode;
	};
}

func main() {
	var list *LinkedList;
	var current *Node;
	var prev *Node;
	var next *Node;
	var value int;
	var length int;
	var i int;
	
	list = &LinkedList{};
	fmt.Println("Insert the number of values:");
	fmt.Scanln(&length);

	i = 0 ;
	fmt.Println("Insert the values:");
	for i < length{
		var v int;
        fmt.Scanln(&v);
		Append(list, v);
		i = i + 1;
    };

	fmt.Println("Original linked list: ");
	current = list.head;
	for current != nil {
		value = current.value;
		fmt.Print(value, " -> ");
		current = current.next;
	};

	fmt.Println("nil");

	current = list.head;
	for current != nil {
		next = current.next;
		current.next = prev;
		prev = current;
		current = next;
	};
	list.head = prev;

	fmt.Println("Reversed linked list: ");
	current = list.head;
	for current != nil {
		value = current.value;
		fmt.Print(value, " -> ");
		current = current.next;
	};
	fmt.Println("nil");
}