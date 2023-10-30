import std::io;


enum Choice
{
	ROCK,
	PAPER,
	SCISSORS
}

enum Result
{
	LOSE,
	DRAW,
	WIN
}

struct Select
{
	Choice c;
	Result r;
}

fault InvalidData
{
	FAILED
}

fn Choice[2]! choicesFromString(String line)
{
	if (line.len != 3) return InvalidData.FAILED?;
	char c1 = line[0];
	if (c1 < 'A' || c1 > 'C') return InvalidData.FAILED?;
	char c2 = line[2];
	if (c2 < 'X' || c2 > 'Z') return InvalidData.FAILED?;
	return { (Choice)(c1 - 'A'), (Choice)(c2 - 'X') };
}

fn Select! selectFromString(String line)
{
	if (line.len != 3) return InvalidData.FAILED?;
	char c1 = line[0];
	if (c1 < 'A' || c1 > 'C') return InvalidData.FAILED?;
	char c2 = line[2];
	if (c2 < 'X' || c2 > 'Z') return InvalidData.FAILED?;
	return { (Choice)(c1 - 'A'), (Result)(c2 - 'X') };
}


fn void part1()
{
	File f = file::open("solution.txt", "rb")!!;
	defer (void)f.close();
	int points = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = io::treadline(&f)!!;
			Choice[2] c = choicesFromString(line)!!;
			points += c[1].ordinal + 1;
			// Draw
			if (c[0] == c[1])
			{
				points += 3;
				continue;
			}
			// Loss
			if ((c[1].ordinal + 1) % 3 == c[0].ordinal)
			{
				continue;
			}
			points += 6;
		};
	}
	io::printfn("The total score is: %d", points);
}

fn void part2()
{
	File f = file::open("solution.txt", "rb")!!;
	defer (void)f.close();
	int points = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = io::treadline(&f)!!;
			Select s = selectFromString(line)!!;
			switch (s.r)
			{
				case WIN:
					points += 6 + 1 + (s.c.ordinal + 1) % 3;
				case LOSE:
					points += 1 + (s.c.ordinal + 2) % 3;
				case DRAW:
					points += 4 + s.c.ordinal;
			}
		};
	}
	io::printfn("The real score is: %d", points);
}

fn void main()
{
	part1();
	part2();
}