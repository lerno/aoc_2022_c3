module day3;
import std::io;
import std::map;

define CharSet = HashMap<char, char>;

fn int evaluate(char c)
{
	int value = c > 'Z' ? c - 'a' + 1 : c - 'A' + 27;
	assert(value >= 1 && value <= 52);
	return value;
}

fn void part1()
{
	File f;
	f.open("rucksack.txt", "rb")!!;
	defer catch(f.close());
	int total = 0;
	while NEXT: (!f.eof())
	{
		@pool()
		{
			CharSet set;
			set.tinit();
			set.clear();
			char[] line = f.tgetline();
			assert(line.len % 2 == 0 && line.len > 0);

			char[] comp1 = line[:line.len / 2];
			char[] comp2 = line[line.len / 2..];

			foreach (c : comp1) set.set(c, c);

			foreach (c : comp2)
			{
				if (try(set.get(c)))
				{
					total += evaluate(c);
					continue NEXT;
				}
			}
			unreachable();
		};
	}
	io::printfln("The sum of priorities is: %d", total);
}

fn void part2()
{
	File f;
	f.open("rucksack.txt", "rb")!!;
	defer catch(f.close());
	int total = 0;
	while NEXT: (!f.eof())
	{
		@pool()
		{
			CharSet set;
			CharSet set2;
			set.tinit();
			set2.tinit();
			char[] line1 = f.tgetline();
			char[] line2 = f.tgetline();
			char[] line3 = f.tgetline();

			assert(line1.len && line2.len && line3.len);

			foreach (c : line1) set.set(c, c);

			foreach (c : line2)
			{
				if (try(set.get(c))) set2.set(c, c);
			}
			foreach (c : line3)
			{
				if (try(set2.get(c)))
				{
					set2.set(c, c);
					total += evaluate(c);
					continue NEXT;
				}
			}
			unreachable();
		};
	}
	io::printfln("The sum of badges is: %d", total);
}

fn void main()
{
	part1();
	part2();
}