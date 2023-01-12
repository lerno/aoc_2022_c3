module day6;
import std::io;

fn bool in_len(char* first, int len)
{
	char c = first[0];
	for (int i = 1; i < len; i++)
	{
		if (first[i] == c) return true;
	}
	return false;
}

fn void find_packet_start(int check_len)
{
	File f;
	f.open("signal.txt", "rb")!!;
	defer catch(f.close());

	while READ: (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			int len = line.len;
			for OUTER: (int i = 0; i < len - check_len; i++)
			{
				for (int j = 0; j < check_len; j++)
				{
					if (in_len(&line[i + j], check_len - j)) continue OUTER;
				}
				io::printfn("Packet start (%d): %d", check_len, i + check_len);
				continue READ;
			}
			unreachable("Invalid data");
		};
	}
}

fn void main()
{
	find_packet_start(4);
	find_packet_start(14);
}