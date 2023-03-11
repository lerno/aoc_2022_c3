module day4;
import std::io;

fn int[2]! parse_range(String range)
{
	String[] ranges = range.tsplit("-");
	assert(ranges.len == 2);
	return { str::to_int(ranges[0]), str::to_int(ranges[1]) };
}

fn bool range_contains(int[2] range1, int[2] range2)
{
	return range1[0] <= range2[0] && range1[1] >= range2[1];
}

fn bool range_contains_any(int[2] range1, int[2] range2)
{
	return !(range1[1] < range2[0] || range1[0] > range2[1]);
}

fn void part1()
{
	File f = file::open("camp.txt", "rb")!!;
	defer (void)f.close();
	int total = 0;
	while NEXT: (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			String[] parts = line.tsplit(",");
			assert(parts.len == 2);

			int[2] range1 = parse_range(parts[0])!!;
			int[2] range2 = parse_range(parts[1])!!;

			if (range_contains(range1, range2) || range_contains(range2, range1)) total++;
		};
	}
	io::printfn("The number of overlaps: %d", total);
}

fn void part2()
{
	File f = file::open("camp.txt", "rb")!!;
	defer (void)f.close();
	int total = 0;
	while NEXT: (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			String[] parts = line.tsplit(",");
			assert(parts.len == 2);

			int[2] range1 = parse_range(parts[0])!!;
			int[2] range2 = parse_range(parts[1])!!;

			if (range_contains_any(range1, range2)) total++;
		};
	}
	io::printfn("The number of partial overlaps: %d", total);
}

fn void main()
{
	part1();
	part2();
}