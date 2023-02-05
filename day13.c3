module day13;
import std::io;
import std::math;
import std::collections::list;

struct PacketPair
{
	Packet* p1;
	Packet* p2;
}

define PacketList = List<Packet*>;

define Packet = List<PacketElement*>;

define PacketPairs = List<PacketPair>;

struct PacketElement
{
	bool is_subpacket;
	union
	{
		Packet* packet;
		int value;
	}
}

fn void Packet.print(Packet* packet)
{
	io::print("[");
	foreach (i, element : packet)
	{
		if (i != 0) io::print(",");
		if (element.is_subpacket)
		{
			element.packet.print();
		}
		else
		{
			io::printf("%d", element.value);
		}
	}
	io::print("]");
}

fn void PacketElement.print(PacketElement* element)
{
	if (element.is_subpacket)
	{
		element.packet.print();
	}
	else
	{
		io::printf("%d", element.value);
	}
}

fn int parse_list(void* list1, String list_inner)
{
	Packet* packet = list1;
	int index = 0;
	int len = list_inner.len;
	while (index < len)
	{
		int start = index;
		char c = list_inner[index];
		if (c >= '0' && c <= '9')
		{
			index++;
			while (index < len)
			{
				c = list_inner[index];
				if (c < '0' || c > '9') break;
				index++;
			}
			PacketElement* element = mem::alloc(PacketElement);
			*element = { .is_subpacket = false, .value = str::to_int(list_inner[start..(index - 1)])!! };
			packet.append(element);
			if (index == len) return len;
			if (c == ']') return index + 1;
			assert(c == ',');
			index++;
			continue;
		}
		if (c == ']') return index + 1;
		assert(c == '[');
		index++;
		PacketElement* element = mem::alloc(PacketElement);
		Packet* inner_list = mem::alloc(Packet);
		inner_list.init();
		index += parse_list(inner_list, list_inner[index..]);
		*element = { .is_subpacket = true, .packet = inner_list };
		packet.append(element);
		if (index == len) return len;
		c = list_inner[index];
		if (c == ']') return index + 1;
		assert(c == ',');
		index++;
	}
	unreachable();
}

fn Packet* packet_from_line(String line)
{
	assert(line[0] == '[' && line[^1] == ']');
	Packet* packet = mem::alloc(Packet);
	packet.init();
	parse_list(packet, line[1..]);
	return packet;
}
fn PacketPairs* load_packets()
{
	File f;
	f.open("packets.txt", "rb")!!;
	defer catch(f.close());
	PacketPairs* packet = mem::alloc(PacketPairs);
	packet.init();
	while (!f.eof())
	{
		@pool()
		{
			Packet* first = packet_from_line(f.tgetline());
			Packet* second = packet_from_line(f.tgetline());
			packet.append({ first, second });
			if (!f.eof()) f.tgetline();
        };
    }
    return packet;
}

fn int PacketElement.compare(PacketElement* e1, PacketElement* e2)
{
	if (e1.is_subpacket && e2.is_subpacket)
	{
		return e1.packet.compare_to(e2.packet);
	}
	if (e1.is_subpacket)
	{
		Packet* packet = e1.packet;
		if (!packet.len()) return 1;
    	switch (packet.get(0).compare(e2))
    	{
    	    case -1: return -1;
    	    case 0: return packet.len() > 1 ? -1 : 0;
    	    case 1: return 1;
    	}
	}
	if (e2.is_subpacket)
	{
		Packet* packet = e2.packet;
		if (!packet.len()) return -1;
    	switch (e1.compare(packet.get(0)))
    	{
    	    case -1: return -1;
    	    case 0: return packet.len() > 1 ? 1 : 0;
    	    case 1: return 1;
    	}
	}
	if (e1.value == e2.value) return 0;
	return e1.value <= e2.value ? 1 : -1;
}

fn int Packet.compare_to(Packet* list1, Packet* list2)
{
	foreach (i, PacketElement* e1 : list1)
	{
		if (i >= list2.len())
		{
			return -1;
		}
		switch (int x = e1.compare(list2.get(i)))
		{
			case 0:
				continue;
			default:
				return x;
		}
	}
	return list2.len() > list1.len() ? 1 : 0;
}

fn void part1(PacketPairs* packets)
{
	int sum = 0;
	foreach (int i, PacketPair pair : packets)
	{
		if (pair.p1.compare_to(pair.p2) >= 0)
		{
			sum += i + 1;
		}
	}
	io::printfn("Sum of ordered pairs: %d", sum);
}


fn void insert_packet(PacketList* list, Packet* new_packet)
{
	foreach (i, packet : list)
	{
		if (new_packet.compare_to(packet) > 0)
		{
			list.insert_at(i, new_packet);
			return;
		}
	}
	list.append(new_packet);
}

fn Packet* create_div(int value)
{
	Packet* packet = mem::alloc(Packet);
	packet.init();
	PacketElement* element = mem::alloc(PacketElement);
	Packet* inner_packet = mem::alloc(Packet);
	*element = { .is_subpacket = true, .packet = inner_packet };
	inner_packet.init();
	PacketElement* element_inner = mem::alloc(PacketElement);
	*element_inner = { .value = value };
	inner_packet.append(element_inner);
	packet.append(element);
	return packet;
}
fn void part2(PacketPairs* packets)
{
	PacketList queue;
	queue.init();
	foreach NEXT: (pair : *packets)
	{
		insert_packet(&queue, pair.p1);
		insert_packet(&queue, pair.p2);
	}
	Packet* div2 = create_div(2);
	Packet* div6 = create_div(6);
	insert_packet(&queue, div2);
	insert_packet(&queue, div6);
	int key = 1;
	foreach (int i, packet : queue)
	{
		switch (packet)
		{
			case div2:
			case div6:
				key *= i + 1;
		}
	}
	io::printfn("Decoder key: %d", key);
}
fn void main()
{
	PacketPairs* packets = load_packets();
	part1(packets);
	part2(packets);
}