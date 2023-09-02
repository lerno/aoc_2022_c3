module day14;
import std::io;
import std::math;

const ENV_SIDE = 1000;
def Environment = int[ENV_SIDE][ENV_SIDE];

enum Result
{
	LOST_IN_ABYSS,
	CAME_TO_REST,
	SAND_CHOKED,
}

enum EnvType
{
	HAS_ABYSS,
	INFINITY_CUTOFF
}

fn int[<2>]! str_to_coord(String str)
{
	String[] parts = str.tsplit(",");
	return { parts[0].to_int(), parts[1].to_int() };
}

fn Environment* load_environment(EnvType type)
{
	File f = file::open("cave.txt", "rb")!!;
	defer (void)f.close();
	Environment* env = calloc(Environment.sizeof);
	int max_y = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = f.treadline();
			int[<2>] last = { 0, 0 };
			foreach (part : line.tsplit(" -> "))
			{
				int[<2>] next = str_to_coord(part)!!;
				if (next[1] > max_y) max_y = next[1];
				if (!last[0])
				{
					(*env)[next[0]][next[1]] = -1;
					last = next;
					continue;
				}
				int[<2>] diff = { math::sign(next[0] - last[0]), math::sign(next[1] - last[1]) };
				while (last != next)
				{
					last += diff;
					(*env)[last[0]][last[1]] = -1;
				}
			}
        };
    }
    if (type == EnvType.INFINITY_CUTOFF)
    {
        for (int i = 0; i < ENV_SIDE; i++)
        {
            (*env)[i][max_y + 2] = -1;
        }
    }
    return env;
}


fn Result simulate_sand_path(Environment* env, int[<2>] sand)
{
	int[<2>] start = sand;
	while (true)
	{
		switch
		{
			case (!(*env)[sand[0]][sand[1] + 1]):
				sand[1]++;
			case (!(*env)[sand[0] - 1][sand[1] + 1]):
				sand += { -1, 1 };
			case (!(*env)[sand[0] + 1][sand[1] + 1]):
				sand += { 1 , 1 };
			default:
				if (start == sand) return SAND_CHOKED;
				(*env)[sand[0]][sand[1]] = 1;
				return CAME_TO_REST;
		}
		if (sand[1] == ENV_SIDE - 1 || sand[0] == 0 || sand[0] == ENV_SIDE - 1) return LOST_IN_ABYSS;
	}
}

fn void part1()
{
	Environment *env = load_environment(EnvType.HAS_ABYSS);
	const int[<2>] SAND_START = { 500, 0 };
	int grains_of_sand = 0;
	while (true)
	{
		if (simulate_sand_path(env, SAND_START) == Result.LOST_IN_ABYSS)
		{
			io::printfn("%d grains of sand came to rest.", grains_of_sand);
			return;
		}
		grains_of_sand++;
	}
}

fn void part2()
{
	Environment *env = load_environment(EnvType.INFINITY_CUTOFF);
	const int[<2>] SAND_START = { 500, 0 };
	int grains_of_sand = 0;
	while (true)
	{
		grains_of_sand++;
		if (simulate_sand_path(env, SAND_START) == Result.SAND_CHOKED)
		{
			io::printfn("%d grains of sand came to rest.", grains_of_sand);
			return;
		}
	}
}

fn void main()
{
	part1();
	part2();
}