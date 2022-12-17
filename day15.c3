module day15;
import std::io;
import std::math;
import std::array::list;
import std::priorityqueue;

define CoordPairList = List<int[<2>][2]>;

fn int[<2>]! parse_coord(char[] s)
{
	char[][] parts = str::tsplit(s, ", y=");
	return { str::to_int(parts[0]), str::to_int(parts[1]) };
}
fn CoordPairList load_sensors()
{
	File f;
	f.open("sensor.txt", "rb")!!;
	defer catch(f.close());
	CoordPairList list;
	list.init();
	while (!f.eof())
	{
		@pool()
		{
			char[] line = f.tgetline();
			line = line["Sensor at x=".len..];
			char[][] parts = str::tsplit(line, ": closest beacon is at x=");
			int[<2>] sensor_at = parse_coord(parts[0])!!;
			int[<2>] beacon_at = parse_coord(parts[1])!!;
			list.append( { sensor_at, beacon_at });
       };
    }
    return list;
}

fn void part1(CoordPairList list)
{
	const int Y_TARGET = 2000000;
	int max_x;
	int min_x;
	foreach (i, pair : list)
	{
		int[<2>] sensor_at = pair[0];
		int[<2>] beacon_at = pair[1];
		int x_diff = math::abs(sensor_at[0] - beacon_at[0]);
		int y_diff = math::abs(sensor_at[0] - beacon_at[0]);
		int range = x_diff + y_diff;
		int min = beacon_at[0] - range;
		int max = beacon_at[0] + range;
		if (i == 0 || min < min_x) min_x = min;
		if (i == 0 || max > max_x) max_x = max;
	}
	int width = max_x - min_x + 1;
	bool[] array = array::tmake(bool, width);
	foreach (pair : list)
	{
		int[<2>] sensor_at = pair[0];
		int[<2>] beacon_at = pair[1];
		int[<2>] diff = math::abs(sensor_at - beacon_at);
		int range = diff.sum();
		int target_diff = math::abs(sensor_at[1] - Y_TARGET);
		range -= target_diff;
		if (range < 0) continue;
		for (int i = -range; i <= range; i++)
		{
			int loc = i + sensor_at[0];
			int index = loc - min_x;
			if (loc == beacon_at[0] && beacon_at[1] == Y_TARGET)
			{
				continue;
			}
			array[index] = true;
		}
	}
	int sum = 0;
	foreach (b : array) if (b) sum++;
	io::printfln("Found %d safe locations", sum);
}

fn bool is_covered(int[<2>] loc, CoordPairList list)
{
	foreach (pair : list)
	{
		int[<2>] sensor_at = pair[0];
		int[<2>] beacon_at = pair[1];
		int[<2>] diff = math::abs(sensor_at - beacon_at);
		int[<2>] diff_loc = math::abs(sensor_at - loc);
		int range = diff.sum();
		int to_loc = diff_loc.sum();
		if (to_loc <= range) return true;
	}
	return false;
}

fn void part2(CoordPairList list)
{
	const int RANGE = 4000000;

	foreach (pair : list)
	{
		int[<2>] sensor_at = pair[0];
		int[<2>] beacon_at = pair[1];
		int[<2>] diff = math::abs(sensor_at - beacon_at);
		// We only need to search the space directly outside of any
		// scanner's range for the hidden beacon
		int range_add = diff.sum() + 1;
		for (int i = -range_add; i <= range_add; i++)
		{
			int[<2>] loc = sensor_at + int[<2>] { i, range_add - i };
			if (loc.comp_lt({ 0, 0 }).or()) continue;
			if (loc.comp_ge({ RANGE, RANGE }).or()) continue;
			if (!is_covered(loc, list))
			{
				io::printfln("Found beacon at %s", loc);
				long frequency = 4000000i64 * loc[0] + loc[1];
				io::printfln("Beacon had tuning frequency %d", frequency);
				return;
			}
		}
	}
	io::println("No beacon found.");
}

fn void main()
{
	CoordPairList list = load_sensors();
	part1(list);
	part2(list);
}