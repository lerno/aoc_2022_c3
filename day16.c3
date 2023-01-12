module day16;
import std::io;
import std::math;
import std::map;
import std::array::list;

define ValveMap = HashMap<String, int>;
define IntPairList = List<int[<2>]>;
ValveMap v;

struct Valve
{
	int id;
	String name;
	int rate;
	int[10] tunnels;
	int tunnel_count;
	int[100] tunnel_cost;
	IntPairList list;
}

fn void populate_tunnels(Valve[] valves, int i, Valve* v, int tunnel, int cost)
{
	if (tunnel == i) return;
	int current_cost = v.tunnel_cost[tunnel];
	if (current_cost && current_cost <= cost) return;
	v.tunnel_cost[tunnel] = cost;
	Valve* other_valve = &valves[tunnel];
	for (int j = 0; j < other_valve.tunnel_count; j++)
	{
		populate_tunnels(valves, i, v, other_valve.tunnels[j], cost + 1);
	}
}

fn Valve[] load_valves(Valve[100]* available_slots)
{
	File f;
	f.open("valves.txt", "rb")!!;
	defer catch(f.close());
	int count = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			String[] parts = str::tsplit(line, " ");
			String name = str::copy(parts[1]);
			String rate_part = parts[4];
			int val = v.@get_or_set(name, (int)v.count);
			Valve *valve_entry = &(*available_slots)[val];
			assert(valve_entry.id == 0);
			count++;
			int rate = str::to_int(rate_part[5..^2])!!;
			int len = parts.len;
			*valve_entry = { .rate = rate, .id = val, .name = name };
			for (int i = 9; i < parts.len; i++)
			{
				String valve = parts[i];
				if (i < parts.len - 1)
				{
					valve = valve[..^2];
				}
				val = v.@get_or_set(str::copy(valve), (int)v.count);
				valve_entry.tunnels[valve_entry.tunnel_count++] = val;
			}
       };
    }
    Valve[] valves = (*available_slots)[:count];
    foreach (int i, &v : valves)
    {
        for (int j = 0; j < v.tunnel_count; j++)
        {
            populate_tunnels(valves, i, v, v.tunnels[j], 1);
        }
    }
    // Make entering the other tunnels super expensive.
    foreach (int i, &v : valves)
    {
        if (!v.rate) continue;
        foreach (&v2 : valves)
        {
            v2.list.append({ i, v2.tunnel_cost[i] });
        }
    }
    assert(count == v.count);
    return valves;
}

fn int visit_valve(int id, Valve[] valves, int* locations, int minutes, int current_flow)
{
	assert(minutes > 0);
	Valve* current = &valves[id];
	assert(locations[id] == 1);
	int total = 0;
	if (current.rate)
	{
		minutes--;
		total += current_flow;
		current_flow += current.rate;
	}
	int best_val = minutes * current_flow;
	if (minutes > 1)
	{
		foreach (pair : current.list)
		{
			int i = pair[0];
			if (locations[i]) continue;
			int cost = pair[1];
			assert(cost);
			if (cost >= minutes) continue;
			locations[i] = 1;
			int val = current_flow * cost + visit_valve(i, valves, locations, minutes - cost, current_flow);
			locations[i] = 0;
			if (val > best_val) best_val = val;
		}
	}
	return best_val + total;
}

fn int visit_valve2(int id, Valve[] valves, int* locations, int minutes, int current_flow, int start_moves, int start)
{
	assert(minutes > 0);
	Valve* current = &valves[id];
	int total = 0;
	if (current.rate)
	{
		minutes--;
		total += current_flow;
		current_flow += current.rate;
	}
	int best_val = minutes * current_flow + visit_valve(start, valves, locations, start_moves, 0);
	if (minutes > 1)
	{
		foreach (pair : current.list)
		{
			int i = pair[0];
			if (locations[i]) continue;
			int cost = pair[1];
			assert(cost);
			if (cost >= minutes) continue;
			locations[i] = 1;
			int val = current_flow * cost + visit_valve2(i, valves, locations, minutes - cost, current_flow, start_moves, start);
			locations[i] = 0;
			if (val > best_val)
			{
				best_val = val;
			}
		}
	}
	return best_val + total;
}

fn void part1(Valve[] valves, int start)
{
	int[100] locations;
	locations[start] = 1;
	int flow = visit_valve(start, valves, &locations, 30, 0);
	io::printfn("Best flow: %d", flow);
}

fn void part2(Valve[] valves, int start)
{
	int[100] locations;
	locations[start] = 1;
	int flow = visit_valve2(start, valves, &locations, 26, 0, 26, start);
	io::printfn("Best flow: %d", flow);
}

fn void main()
{
	v.init();
	int start = -1;
	Valve[] valves = load_valves(&&Valve[100] {});
	foreach (int i, valve : valves)
	{
		if (valve.name == "AA") start = i;
	}
	part1(valves, start);
	part2(valves, start);
}