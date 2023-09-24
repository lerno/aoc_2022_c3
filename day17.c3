module day17;
import std::io;
import std::math;
import std::collections::map;
import std::collections::list;

def StateCacheMap = HashMap(<StateCache, int>);

struct StateCache
{
	int shape_index;
	int wind_index;
	GameRow[128] rows;
	int height;
}

fn uint StateCache.hash(StateCache* cache)
{
	uint hash = cache.wind_index * 5 + cache.shape_index;
	return hash * 31 + cache.height;
}

macro bool StateCache.equals(StateCache* cache, StateCache other)
{
	if (cache.shape_index != other.shape_index) return false;
	if (cache.wind_index != other.wind_index) return false;
	if (cache.height != other.height) return false;
	for (int i = 0; i < cache.height; i++)
	{
		if (cache.rows[i] != other.rows[i]) return false;
	}
	return true;
}

fn DString load_jets()
{
	File f = file::open("jets.txt", "rb")!!;
	defer (void)f.close();
	return f.readline();
}

struct Shape
{
	int width;
	int height;
	int[4][4] shape;
}

Shape[5] shapes = {
	{
		4, 1,
		{ { 1, 1, 1, 1 }, {}, {}, {} }
	},
	{
		3, 3,
		{
			{ 0, 1, 0, 0 },
			{ 1, 1, 1, 0 },
			{ 0, 1, 0, 0 }, {}
		}
	},
	{
		3, 3,
		{
			{ 1, 1, 1, 0 },
            { 0, 0, 1, 0 },
			{ 0, 0, 1, 0 },
			{} }
	},
	{
		1, 4,
		{
			{ 1, 0, 0, 0 },
			{ 1, 0, 0, 0 },
			{ 1, 0, 0, 0 },
			{ 1, 0, 0, 0 }
		}
	},
	{
		2, 2,
		{
			{ 1, 1, 0, 0 },
			{ 1, 1, 0, 0 }, {}, {}
		}
	}
};

def GameRow = distinct char;
GameRow[1000] game;

macro bool GameRow.is_full(GameRow row)
{
	return row == 127;
}

macro bool GameRow.bit(GameRow row, int bit)
{
	return ((GameRow)(1 << bit) & row) != 0;
}

macro bool GameRow.set_bit(GameRow* row, int bit)
{
	return (bool)(*row |= (GameRow)1 << bit);
}

fn int find_height()
{
	int size = game.len;
	for (int i = 0; i < size; i++)
	{
		if (game[i] == 0) return i;
	}
	unreachable("Max exceeded");
}

fn int find_lowest_bound(int height)
{
	GameRow ok;
	for (int i = height; i >= 0; i--)
	{
		ok |= game[i];
		if (ok.is_full()) return i;
	}
	return 0;
}

fn bool check_collision(Shape* shape, int[<2>] location)
{
	if (location[1] < 0) return true;
	if (location[0] < 0) return true;
	if (location[0] + shape.width > 7) return true;
	int y_offset = shape.height;
	for (int y = 0; y < shape.height; y++)
	{
		for (int x = 0; x < shape.width; x++)
		{
			if (!shape.shape[y][x]) continue;
			if (game[location[1] + y].bit(location[0] + x)) return true;
		}
	}
	return false;
}

fn void land_shape(Shape* shape, int[<2>] location)
{
	for (int y = 0; y < shape.height; y++)
	{
		for (int x = 0; x < shape.width; x++)
		{
			if (!shape.shape[y][x]) continue;
			game[location[1] + y].set_bit(location[0] + x);
		}
	}
}

fn void draw_field()
{
	io::printn("+-----+");
	for (int i = find_height(); i >= 0; i--)
	{
		GameRow row = game[i];
		for (int j = 0; j < 7; j++)
		{
			io::putchar(row.bit(j) ? '#' : '.');
		}
		io::printn();
	}
	io::printn("+-----+");
}

macro long adjust_lowest_bounds()
{
	int height = find_height();
	int bound = find_lowest_bound(height);
	if (bound == 0) return 0;
	for (int i = bound; i < height; i++)
	{
		game[i - bound] = game[i];
	}
	for (int i = height - bound; i < height; i++)
	{
		game[i] = 0;
	}
	return bound;
}

macro @drop_rock(String winds, int &shape_index, isz &wind_index)
{
	int start = find_height() + 3;
	Shape* current_shape = &shapes[shape_index];
	shape_index = (shape_index + 1) % 5;
	int[<2>] location = { 2, start };
	while (true)
	{
		char jet = winds[wind_index];
		wind_index = (wind_index + 1) % winds.len;
		int[<2>] new_loc = location + { jet == '<' ? -1 : 1, 0 };
		if (check_collision(current_shape, new_loc))
		{
			new_loc = location;
		}
		location = new_loc;
		new_loc[1]--;
		if (check_collision(current_shape, new_loc))
		{
			land_shape(current_shape, location);
			break;
		}
		location = new_loc;
	}
}

fn void solve(String winds, long rocks)
{
	game = {};
	int shape_index = 0;
	isz wind_index = 0;
	long offset = 0;
	StateCacheMap map;
	map.init(1024);
	long max = rocks;
	bool check_cache = true;
	long desired_drops = rocks;
	long first_cycle_hit = -1;
	long cycle_start_height = 0;
	long cycle_start_rock = 0;
	for (long i = 0; i < max; i++)
	{
		if (check_cache)
		{
			int height = find_height();
            int bottom = find_lowest_bound(height);
            StateCache cache = { .shape_index = shape_index, .wind_index = (int)wind_index, .height = height - bottom - 1 };
            assert(height - bottom < (int)cache.rows.len);
            for (int k = bottom; k < height; k++)
            {
            	cache.rows[k - bottom] = game[k];
            }
            int! index = map.get(cache);
            if (try index)
            {
                {|
                    if (first_cycle_hit < 0)
                    {
                        first_cycle_hit = index;
                        cycle_start_rock = i;
                        cycle_start_height = find_height() + offset;
                        return;
					}
                    if (index != first_cycle_hit) return;
                    long cycle_height = find_height() + offset - cycle_start_height;
                    long cycle_len = (long)i - cycle_start_rock;
	                desired_drops -= i;
                    long cycles = desired_drops / cycle_len;
                    offset += cycles * cycle_height;
                    max = desired_drops % cycle_len;
                    i = 0;
                    check_cache = false;
                |};
            }
            else
            {
				map.set(cache, (int)i);
            }
        }
		@drop_rock(winds, shape_index, wind_index);
		offset += adjust_lowest_bounds();
	}
	io::printfn("Height was: %d", find_height() + offset);
}

fn void main()
{
	DString s = load_jets();
	defer s.free();
	solve(s.str_view(), 2022);
	solve(s.str_view(), 1000000000000i64);
}