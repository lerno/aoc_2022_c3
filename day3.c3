module day3;
import std::io;
import std::collections::map;

def CharSet = HashMap(<char, char>);

fn int evaluate(char c)
{
	int value = c > 'Z' ? c - 'a' + 1 : c - 'A' + 27;
	assert(value >= 1 && value <= 52);
	return value;
}

fn void part1()
{
	File f = file::open("rucksack.txt", "rb")!!;
	defer (void)f.close();
	int total = 0;
	while NEXT: (!f.eof())
	{
		@pool()
		{
			CharSet set;
			set.temp_init();
			set.clear();
			String line = io::treadline(&f)!!;
			assert(line.len % 2 == 0 && line.len > 0);

			String comp1 = line[:line.len / 2];
			String comp2 = line[line.len / 2..];

			foreach (c : comp1) set.set(c, c);

			foreach (c : comp2)
			{
				if (@ok(set.get(c)))
				{
					total += evaluate(c);
					continue NEXT;
				}
			}
			unreachable();
		};
	}
	io::printfn("The sum of priorities is: %d", total);
}

fn void part2()
{
	File f = file::open("rucksack.txt", "rb")!!;
	defer (void)f.close();
	int total = 0;
	while NEXT: (!f.eof())
	{
		@pool()
		{
			CharSet set;
			CharSet set2;
			set.temp_init();
			set2.temp_init();
			String line1 = io::treadline(&f)!!;
			String line2 = io::treadline(&f)!!;
			String line3 = io::treadline(&f)!!;

			assert(line1.len && line2.len && line3.len);

			foreach (c : line1) set.set(c, c);

			foreach (c : line2)
			{
				if (@ok(set.get(c))) set2.set(c, c);
			}
			foreach (c : line3)
			{
				if (@ok(set2.get(c)))
				{
					set2.set(c, c);
					total += evaluate(c);
					continue NEXT;
				}
			}
			unreachable();
		};
	}
	io::printfn("The sum of badges is: %d", total);
}

fn void main()
{
	part1();
	part2();
}