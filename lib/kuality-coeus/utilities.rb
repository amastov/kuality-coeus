module Utilities

  include StringFactory

  def get(item)
    instance_variable_get(snakify(item))
  end

  def set(item, obj)
    instance_variable_set(snakify(item), obj)
  end

  def make_user(opts={})
    un=opts[:user]
    role=opts[:role]
    un ||= role
    $users << set(un, (make UserObject, opts))
    $users[-1]
  end

  def make_role(opts={})
    name = opts[:name]
    name ||= 'role'
    set(name, (make RoleObject, opts))
  end

  def random_percentage
    random_dollar_value(100)
  end

  def days_in_month(year, month)
    Date.new(year, month, -1).day.to_i
  end
  module_function :days_in_month

  def datify(date_string)
    Date.strptime date_string, '%m/%d/%Y'
  end
  module_function :datify

  def difference_in_months(start, finish)
    s = datify(start)
    f = datify(finish)
    raise 'First date must be earlier than second.' if s > f
    first_full = s.day == 1 ? s : s.next_month
    last_full_month = f.day == days_in_month(f.year, f.month) ? f.month+1 : f.month
    12*(f.year-first_full.year) + (last_full_month - first_full.month)
  end

  private

  def snakify(item)
    item.to_s[0]=='@' ? item : "@#{damballa(item.to_s)}"
  end

end