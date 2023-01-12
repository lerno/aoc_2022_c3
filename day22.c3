module day22;
import std::io;
import std::math;

const RIGHT = 0;
const DOWN = 1;
const LEFT = 2;
const UP = 3;

enum MapType : char
{
	VOID,
	SPACE,
	BLOCK
}

int[200][200] map;
String commands;
int[<2>] start = { -1, -1 };
int side;
int width;
int height;
int width_spaces;

fn void load_map()
{
	File f;
	f.open("map.txt", "rb")!!;
	defer catch(f.close());
	int y = 0;
	width = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			if (line.len > width) width = line.len;
			if (!line.len) break;
			foreach (int x, c : line)
			{
				switch (c)
				{
					case '#':
						map[x][y] = MapType.BLOCK;
					case '.':
						if (start[0] < 0)
						{
							start = { x, y };
						}
						map[x][y] = MapType.SPACE;
					case ' ':
						map[x][y] = MapType.VOID;
					default:
						unreachable();
				}
			}
			y++;
		};
	}
	height = y;
	side = y > width ? y / 4 : width / 4;
	width_spaces = width / side;
	commands = str::copy(f.tgetline());
}

fn int region_from_pos(int[<2>] pos)
{
	int x_region = pos[0] / side;
	int y_region = pos[1] / side;
	return y_region * width_spaces + x_region;
}

fn int[<2>] region_start(int region)
{
	return { (region % width_spaces) * side, (region / width_spaces ) * side };
}

fn int[<2>] update(int[<2>] pos, int* facing_ref, int to_facing, int region)
{
	int facing = *facing_ref;
	*facing_ref = to_facing;
	int[<2>] rel_pos = pos % int[<2>] { side, side };
	bool reverse = (to_facing - facing + 4) % 4 == 2; // Reverse on UP <-> DOWN LEFT <-> RIGHT
	if (reverse) rel_pos = int[<2>] { side - 1, side - 1 } - rel_pos;
	int[<2>] res;
	int val;
	switch (facing)
	{
		case LEFT:
		case RIGHT:
			val = rel_pos[1];
		case DOWN:
		case UP:
			val = rel_pos[0];
	}
	switch (to_facing)
	{
		case DOWN: res = { val, 0 };
		case RIGHT: res = { 0, val };
		case LEFT: res = { side - 1, val };
		case UP: res = { val, side - 1 };
	}
	return region_start(region) + res;
}


// This wrapping only works for the particular layout of the cube in the example.
fn void wrap(int[<2>]* pos_ref, int* facing)
{
	int[<2>] pos = *pos_ref;
	switch (region_from_pos(pos))
	{
		case 1:
			switch (*facing)
			{
				case RIGHT:
					unreachable();
				case DOWN:
					unreachable();
				case UP:
					*pos_ref = update(pos, facing, RIGHT, 9);
				case LEFT:
					*pos_ref = update(pos, facing, RIGHT, 6);
			}
		case 2:
			switch (*facing)
			{
				case LEFT:
					unreachable();
				case RIGHT:
					*pos_ref = update(pos, facing, LEFT, 7);
				case UP:
					*pos_ref = update(pos, facing, UP, 9);
				case DOWN:
					*pos_ref = update(pos, facing, LEFT, 4);
			}
		case 4:
			switch (*facing)
			{
				case LEFT:
					*pos_ref = update(pos, facing, DOWN, 6);
				case RIGHT:
					*pos_ref = update(pos, facing, UP, 2);
				case DOWN:
					unreachable();
				case UP:
					unreachable();
			}
		case 6:
			switch (*facing)
			{
				case LEFT:
					*pos_ref = update(pos, facing, RIGHT, 1);
				case RIGHT:
					unreachable();
				case DOWN:
					unreachable();
				case UP:
					*pos_ref = update(pos, facing, RIGHT, 4);
			}
		case 7:
			switch (*facing)
			{
				case LEFT:
					unreachable();
				case UP:
					unreachable();
				case RIGHT:
					*pos_ref = update(pos, facing, LEFT, 2);
				case DOWN:
					*pos_ref = update(pos, facing, LEFT, 9);
			}
		case 9:
			switch (*facing)
			{
				case DOWN:
        		    *pos_ref = update(pos, facing, DOWN, 2);
        		case RIGHT:
        		    *pos_ref = update(pos, facing, UP, 7);
        		case UP:
        		    unreachable();
        		case LEFT:
					*pos_ref = update(pos, facing, DOWN, 1);
			}
		default:
			unreachable();
	}

}

fn int[<2>] facing_diff(int facing)
{
	switch (facing)
	{
		case RIGHT: return { 1, 0 };
		case DOWN: return { 0, 1 };
		case LEFT: return { -1, 0 };
		case UP: return { 0, -1 };
		default: unreachable();
	}
}

macro MapType map_at(int[<2>] pos)
{
	return (MapType)map[pos[0]][pos[1]]; // Bug with cast.
}

fn void part1()
{
	int[<2>] pos = start;
	int len = commands.len;
	int index = 0;
	int facing = 0;
	while (index < len)
	{
		int steps = -1;
		int new_facing = void;
		for (int i = index; i < len; i++)
		{
			if (commands[i] >= 'A')
			{
				steps = str::to_int(commands[index..(i - 1)])!!;
				new_facing = commands[i] == 'R' ? 1 : -1;
				index = i + 1;
				break;
			}
		}
		if (steps == -1)
		{
			new_facing = 4;
			steps = str::to_int(commands[index..])!!;
			index = len;
		}
		int[<2>] move = facing_diff(facing);
		for WALK: (int i = 0; i < steps; i++)
		{
			int[<2>] old = pos;
			pos += move;
			if (pos[0] == width) pos[0] = 0;
			if (pos[1] == height) pos[1] = 0;
			if (pos[0] == -1) pos[0] = width - 1;
			if (pos[1] == -1) pos[1] = height - 1;
			switch (map_at(pos))
			{
				case MapType.SPACE:
					continue WALK;
				case MapType.VOID:
					switch
					{
						case move[0] > 0: pos[0] = 0;
						case move[0] < 0: pos[0] = width - 1;
						case move[1] > 0: pos[1] = 0;
						case move[1] < 0: pos[1] = height - 1;
					}
					while (map_at(pos) == MapType.VOID) pos += move;
					switch (map_at(pos))
					{
						case MapType.BLOCK:
							pos = old;
							break WALK;
						case MapType.SPACE:
							continue WALK;
					}
					unreachable();
				case MapType.BLOCK:
					pos = old;
					break WALK;
				default:
					unreachable();
			}
		}
		facing = (4 + new_facing + facing) % 4;
	}
	long value = (pos[0] + 1i64) * 4i64 + (pos[1] + 1i64) * 1000i64 + facing;
	io::printfn("Password: %d", value);
}

fn void part2()
{
	int[<2>] pos = start;
	int len = commands.len;
	int index = 0;
	int facing = 0;
	while (index < len)
	{
		int steps = -1;
		int new_facing = void;
		for (int i = index; i < len; i++)
		{
			if (commands[i] >= 'A')
			{
				steps = str::to_int(commands[index..(i - 1)])!!;
				new_facing = commands[i] == 'R' ? 1 : -1;
				index = i + 1;
				break;
			}
		}
		if (steps == -1)
		{
			new_facing = 4;
			steps = str::to_int(commands[index..])!!;
			index = len;
		}
		int[<2>] move = facing_diff(facing);
		for WALK: (int i = 0; i < steps; i++)
		{

			int[<2>] old = pos;
			pos += move;
			if (pos.comp_lt({ 0, 0 }).or() || pos.comp_ge({ width, height}).or() || map_at(pos) == MapType.VOID)
			{
				pos = old;
				int wrap_facing = facing;
				wrap(&pos, &wrap_facing);
				switch (map_at(pos))
				{
					case MapType.BLOCK:
						pos = old;
						break WALK;
					case MapType.SPACE:
						facing = wrap_facing;
						move = facing_diff(facing);
						continue WALK;
				}
			}
			switch (map_at(pos))
			{
				case MapType.SPACE:
					continue WALK;
				case MapType.VOID:
					unreachable();
				case MapType.BLOCK:
					pos = old;
					break WALK;
				default:
					unreachable("invalid map");
			}
		}
		facing = (4 + new_facing + facing) % 4;
	}
	long value = (pos[0] + 1i64) * 4i64 + (pos[1] + 1i64) * 1000i64 + facing;
	io::printfn("Password: %d", value);
}

fn void main()
{
	load_map();
	part1();
	part2();
}