module day18;
import std::io;
import std::math;
import std::collections::map;
import std::collections::list;

const MAX = 22;
int[MAX][MAX][MAX] locations;

fn void load_lava()
{
	File f = file::open("lava.txt", "rb")!!;
	defer (void)f.close();
	while (!f.eof())
	{
		@pool()
		{
			String[] parts = f.tgetline().tsplit(",");
			locations[parts[0].to_int()!!][parts[1].to_int()!!][parts[2].to_int()!!] = 7;
		};
	}
}

fn void remove_lava_faces()
{
	foreach (i, &segment : locations)
	{
		foreach (j, &slice : segment)
		{
			foreach (k, &element : slice)
			{
				if (!*element) continue;
				if (k < (MAX - 1) && (*slice)[k + 1])
				{
					(*element)--;
					(*slice)[k + 1]--;
				}
				if (j < (MAX - 1) && (*segment)[j + 1][k])
				{
					(*element)--;
					(*segment)[j + 1][k]--;
				}
				if (i < (MAX - 1) && locations[i + 1][j][k])
				{
					(*element)--;
                	locations[i + 1][j][k]--;
				}
			}
		}
	}
}

fn void count_faces()
{
	int faces = 0;
	foreach (i, &segment : locations)
	{
		foreach (j, &slice : segment)
		{
			foreach (el : slice)
			{
				if (el < 1) continue;
				faces += el - 1;
			}
		}
	}
	io::printfn("Faces: %d", faces);
}

fn void fill(int[<3>] loc)
{
	// Do we exceed the range?
	if (!loc.comp_lt({ MAX, MAX, MAX }).and()) return;
	// Less than zero?
	if (loc.comp_lt({ 0, 0, 0}).or()) return;
	int* location = &locations[loc[0]][loc[1]][loc[2]];
	int val = *location;
	// Already visited
	if (val > 0) return;
	// Fill
	*location = 100;
	static int[<3>][*] directions = {
		{ -1, 0, 0 },
		{ 1, 0, 0 },
		{ 0, -1, 0 },
		{ 0, 1, 0},
		{ 0, 0, -1 },
		{ 0, 0, 1 }
	};
	foreach (int[<3>] dir : directions)
	{
		fill(dir + loc);
	}
}

fn void part1()
{
	load_lava();
	remove_lava_faces();
	count_faces();
}

fn void remove_fill()
{
	foreach (i, &segment : locations)
	{
		foreach (j, &slice : segment)
		{
			foreach (&el : slice)
			{
				switch (*el)
				{
					case 100:
						*el = 0;
					case 0:
						*el = 7;
					default:
						break;
				}
			}
		}
	}
}
fn void part2()
{
	load_lava();
	fill({ 0, 0, 0});
	remove_fill();
	remove_lava_faces();
	count_faces();
}
fn void main()
{
	part1();
	part2();
}