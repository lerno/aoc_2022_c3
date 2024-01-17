module day12;
import std::io;
import std::math;
import std::collections::list;

def MapList = List(<String>);

struct Map
{
	MapList map;
	int[<2>] start;
	int[<2>] end;
}

struct WalkedMap
{
	int* walked;
	int[<2>] size;
}

fn char Map.height_at(Map* map, int[<2>] pos)
{
	return map.map.get(pos[1])[pos[0]];
}

fn WalkedMap* Map.create_temp_empty_walked_map(Map* map)
{
	usz height = map.map.len();
	usz width = map.map.get(0).len;
	WalkedMap *w = mem::temp_new(WalkedMap);
	w.walked = tcalloc(int.sizeof * height * width);
	w.size = { (int)width, (int)height };
	return w;
}


fn int WalkedMap.steps_at(WalkedMap* this, int[<2>] loc)
{
	return this.walked[loc[1] * this.size[0] + loc[0]];
}

fn bool WalkedMap.walk(WalkedMap* this, int[<2>] loc, int steps)
{
	int* steps_at_ref = &this.walked[loc[1] * this.size[0] + loc[0]];
	int steps_at = *steps_at_ref;
	if (steps_at && steps_at <= steps) return false;
	*steps_at_ref = steps;
	return true;
}

fn void WalkedMap.show(WalkedMap* this)
{
	io::printn("-----------------");
	for (int y = 0; y < this.size[1]; y++)
	{
		io::printf("|");
		for (int x = 0; x < this.size[0]; x++)
		{
			int val = this.walked[x + y * this.size[0]];
			io::printf("%c", val ? val + '0' - 1 : ' ');
		}
		io::printn("|");
	}
}

fn Map* load_heightmap()
{
	File f = file::open("heightmap.txt", "rb")!!;
	defer (void)f.close();
	Map* map = mem::alloc(Map);
	map.map.new_init();
	while (!f.eof())
	{
		@pool()
		{
			String line = io::readline(&f)!!;
			foreach (int i, &c : line)
			{
				if (*c == 'S')
				{
					*c = 'a';
					map.start = { i, (int)map.map.len() };
					continue;
				}
				if (*c == 'E')
				{
					*c = 'z';
					map.end = { i, (int)map.map.len() };
					continue;
				}
			}
			map.map.append(line);
        };
    }
    return map;
}

fn void Map.fill_in_direction(Map* map, WalkedMap* walked, int[<2>] current, int[<2>] direction, int steps, bool reverse)
{
	int[<2>] loc = current + direction;
	if (loc[0] < 0 || loc[1] < 0) return;
	if (loc[0] >= walked.size[0] || loc[1] >= walked.size[1]) return;
	int to_height = map.height_at(loc);
	int current_height = map.height_at(current);
    int diff = to_height - current_height;
    if (reverse)
    {
        if (diff < -1) return;
    }
    else
    {
        if (diff > 1) return;
    }
    bool first_step = walked.walk(loc, steps);
    if (first_step)
    {
        map.fill(walked, loc, steps, reverse);
    }
}

fn void Map.fill(Map* map, WalkedMap* walked, int[<2>] current, int steps, bool reverse)
{
	foreach (int[<2>] dir : { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } })
	{
		map.fill_in_direction(walked, current, dir, steps + 1, reverse);
	}
}

fn void part1(Map* map)
{
	@pool()
	{
		WalkedMap* w = map.create_temp_empty_walked_map();
		map.fill(w, map.start, 0, false);
		io::printfn("Fewest steps: %d", w.steps_at(map.end));
	};
}

fn void part2(Map* map)
{
	@pool()
	{
		WalkedMap* w = map.create_temp_empty_walked_map();
		map.fill(w, map.end, 0, true);
		int min = 10000000;
		for (int y = 0; y < w.size[1]; y++)
		{
			for (int x = 0; x < w.size[0]; x++)
			{
				int[<2>] loc = { x, y };
				if (map.height_at(loc) != 'a') continue;
				int steps = w.steps_at(loc);
				if (steps && steps < min) min = steps;
			}
		}
		io::printfn("Fewest steps: %d", min);
	};
}

fn void main()
{
	Map* map = load_heightmap();
	part1(map);
	part2(map);
}