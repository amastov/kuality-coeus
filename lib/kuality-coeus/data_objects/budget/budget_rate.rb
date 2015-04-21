# A simplified Rates class used in Budget Objects for Rates calculations...
class BudgetRateObject < DataFactory

  attr_reader :rate_class_type, :rate_class_code, :description, :on_campus,
              :fiscal_year, :start_date, :institute_rate, :applicable_rate

  def initialize(browser, opts={})
    set_options(opts)
  end

  def end_date
    (@start_date >> 12)-1
  end

end

class BudgetRatesCollection < CollectionFactory

  contains BudgetRateObject

  def build(rates, start_date, end_date, campus, ur_type, fa_type)
    all_rates = noob
    rates.each { |r_c_t, rs|
      next if rs.empty?
      rs.each { |rate|
      item = BudgetRateObject.new nil, rate_class_type: r_c_t,
          rate_class_code: rate[:rate_class_code],
          description: rate[:description],
          on_campus: rate[:on_campus],
          fiscal_year: rate[:fiscal_year],
          start_date: rate[:start_date],
          institute_rate: rate[:institute_rate],
          applicable_rate: rate[:applicable_rate]
      all_rates << item
      }
    }
    in_range_rates = all_rates.in_range(start_date, end_date)
    unless campus == 'Default'
      in_range_rates.campus!(campus)
    end
    self << in_range_rates.non_fa_rates
    self << in_range_rates.fa_rates(fa_type)
    self << in_range_rates.fa_rates(ur_type) unless ur_type == fa_type
    self.flatten!
  end

  def in_range(start_date, end_date)
    st = self.find_all { |rate| rate.start_date <= start_date }
    # Find dupes in this list and discard earlier items...
    keep = []
    st.each { |r|
      ar = st.find_all { |i|
            i.description == r.description &&
            i.on_campus == r.on_campus &&
            i.rate_class_code == r.rate_class_code &&
            i.rate_class_type == r.rate_class_type
      }
      if ar.size > 1
        ar.sort_by { |x| x.start_date }
      end
      keep << ar[-1] unless keep.include? ar[-1]
    }
    br = noob
    br << keep
    ed = self.find_all { |rate| rate.start_date <= end_date } - st
    br << ed
    x = br.flatten
    x.delete_bad_inflations! start_date
  end

  def campus!(type)
    camp = { 'All On'=>'Yes','All Off'=>'No'}
    self.delete_if { |rate| rate.on_campus != camp[type] }
  end

  def non_personnel
    br = noob
    np = self.find_all { |r|
      r.rate_class_type != 'Fringe Benefits' &&
          r.rate_class_type != 'Vacation' &&
          r.description !~ /salar/i
    }
    br << np
    br.flatten
  end

  def inflation
    br = noob
    br << self.find_all { |r| r.rate_class_type=='Inflation' }
    br.flatten
  end

  def non_fa_rates
    nfa = noob
    nfa << self.find_all { |r| r.rate_class_type != 'F & A' }
    nfa.flatten
  end

  def fa_rates(rate_class_code)
    br = noob
    br << self.find_all { |r| r.rate_class_code == rate_class_code && r.rate_class_type == 'F & A' }
    br.flatten
  end

  # Use this method for an already-filtered collection of rates...
  def f_and_a
    self.find_all { |r| r.rate_class_type=='F & A'}
  end

  def delete_bad_inflations!(start_date)
    self.delete_if { |r|
      r.rate_class_type == 'Inflation' &&
          (r.end_date) < start_date
    }
  end

  private

  def noob
    BudgetRatesCollection.new @browser
  end

end