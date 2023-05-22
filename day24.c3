module day24;
import std::io;
import std::math;
import std::collections::list;

def CharsArray = List<String>;

const int PADDING = 100;

const MAX_WIDTH = 120;
const MAX_HEIGHT = 40;
const MAX_PHASE = MAX_WIDTH * MAX_HEIGHT;

char[MAX_WIDTH][MAX_HEIGHT] map;
int[MAX_WIDTH][MAX_HEIGHT][MAX_PHASE] map_cost;
bool[MAX_WIDTH][MAX_HEIGHT][MAX_PHASE] blizzard;
int width;
int height;
int common;
fn void load_map()
{
	File f = file::open("blizzard.txt", "rb")!!;
	defer (void)f.close();
	@pool()
	{
		String line = f.tgetline();
		width = line.len - 2;
	};
	height = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			if (line[1] == '#') break;
			line = line[1..^2];
			foreach (int i, c : line)
			{
				map[height][i] = c;
			}
			height++;
		};
	}
	assert(MAX_HEIGHT > height);
	assert(MAX_WIDTH > width);
	int a = width;
	int b = height;
	while (a != b)
	{
		if (a > b)
		{
			a -= b;
		}
		else
		{
			b -= a;
		}
	}
	common = width * height / a;
	assert(common < 1000);
	for (int i = 0; i < height; i++)
	{
		for (int j = 0; j < width; j++)
		{
			switch (map[i][j])
			{
				case '.':
					continue;
				case '^':
					for (int it = 0; it < common; it++)
					{
						int off = it % (height * 2);
						blizzard[it][(i - off + height * 2) % height][j] = true;
					}
				case 'v':
					for (int it = 0; it < width * height; it++)
					{
						blizzard[it][(i + it) % height][j] = true;
					}
				case '>':
					for (int it = 0; it < width * height; it++)
					{
						blizzard[it][i][(j + it) % width] = true;
					}
				case '<':
					for (int it = 0; it < width * height; it++)
					{
						int off = it % (width * 2);
						blizzard[it][i][(j + width * 2 - off) % width] = true;
					}
				default:
					unreachable("Invalid element");
			}
		}
	}

}

fn void explore(int[<2>] loc, int round)
{
	if (round > 10000) return;
	if (loc.comp_lt({ 0, 0 }).or() || loc.comp_ge({width, height}).or()) return;
	int seq = round % common;
	bool is_blizzard = blizzard[seq][loc[1]][loc[0]];
	if (is_blizzard) return;
	int current_cost = map_cost[seq][loc[1]][loc[0]];
	if (current_cost > 0 && current_cost <= round) return;
	map_cost[seq][loc[1]][loc[0]] = round;
	round++;
	for (int i = 0; i < 5; i++)
	{
		switch (i)
		{
			case 0:
				explore(loc + { 0, 1 }, round);
			case 1:
				explore(loc + { 0, -1 }, round);
			case 2:
				explore(loc + { 1, 0 }, round);
			case 3:
				explore(loc + { -1, 0 }, round);
			case 4:
				explore(loc, round);
			default:
				unreachable();
		}
	}

}

fn void solve()
{
	int round = 0;
	while (blizzard[round % common][0][0]) round++;
	explore({ 0, 0 }, round);

	int min = 1000000000;
	for (int i = 0; i < common; i++)
	{
		int cost = map_cost[i][height - 1][width - 1];
		if (cost > 0 && cost < min) min = cost;
	}
	io::printfn("Cost: %d", min + 1);
	mem::clear(&map_cost, int.sizeof * MAX_PHASE * MAX_HEIGHT * MAX_WIDTH);
	round = min + 1;
	for (int i = 0; i < common; i++)
	{
	    explore({ width - 1, height - 1 }, round + i);
	}
    min = 999999999;
    for (int i = 0; i < common; i++)
    {
    	int cost = map_cost[i][0][0];
    	if (cost > 0 && cost < min) min = cost;
    }
	round = min + 1;
	mem::clear(&map_cost, int.sizeof * MAX_PHASE * MAX_HEIGHT * MAX_WIDTH);
	for (int i = 0; i < common; i++)
	{
	    explore({ 0, 0 }, round + i);
	}
	min = 1000000000;
	for (int i = 0; i < common; i++)
	{
		int cost = map_cost[i][height - 1][width - 1];
		if (cost > 0 && cost < min) min = cost;
	}
    io::printfn("Cost: %d", min + 1);
}


fn void main()
{
	load_map();
	solve();
}