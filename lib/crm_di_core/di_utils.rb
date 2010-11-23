@di_trace = false

def sendd(f, s)
  if @di_trace
    puts "=" * 80
    puts "= PLUGINROOT#{f[65..255]}"
    puts "=" + ("-" * 79)
    puts "= #{s}"
    puts "=" * 80
  end
end  

def znil(v)
  v.to_s == "0" ? nil : v
end

def nilz(v)
  v.nil? ? 0 : v
end