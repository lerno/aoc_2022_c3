import std::io;

enum Choice : int(int points)
{
	ROCK(1),
	PAPER(2),
	SCISSORS(3)
}

enum Result : int(int points, int offset)
{
	LOSE(0, 2),
	DRAW(3, 0),
	WIN(6, 1),
}

fn Choice Choice.loses_to(Choice c) => (Choice)((c.ordinal + 1) % 3);
fn Choice Choice.defeats(Choice c) => (Choice)((c.ordinal + 2) % 3);

fn Result Choice.result_against(Choice c, Choice other)
{
	if (c == other) return Result.DRAW;
	if (other.defeats() == c) return Result.LOSE;
	return Result.WIN;
}

fn Choice Result.choice_from_other(Result r, Choice other) => (Choice)((other.ordinal + r.offset) % 3);

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
			Choice[2] c = choicesFromString(io::treadline(&f)!!)!!;
			points += c[1].points + c[1].result_against(c[0]).points;
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
			Select s = selectFromString(io::treadline(&f)!!)!!;
			points += s.r.points + s.r.choice_from_other(s.c).points;
		};
	}
	io::printfn("The real score is: %d", points);
}

fn void main()
{
	part1();
	part2();
}