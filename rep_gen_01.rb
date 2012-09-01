#####################

$stdout = File.open('files/Result.csv', 'w')
$stderr = File.open('files/Errors.txt', 'a')

#==========config============
input_file = "files/input 080712.csv"
cash_flow_users = ["Bobby","Leha","Igor","SHOPS"]
c_name = 0
c_goods = 1
 c_date_bill = 2
c_track = 5
c_consolidation_price = 6
c_us_price = 7
c_shipping_us = 8
c_price_rub = 11
 c_date_purchase = 12
 c_admin_purchase = 13
c_shipping = 14
c_bill = 15
c_total = 16
 c_date_pay = 17
 c_admin_pay = 18
package_price	= 188.08		#FULL PACKAGE PRICE ALWAYS SET!!!  consolidation Price will be substracted (#3 "package_price_wo_consolidation")	|use dot (.) as delimeter|
dollar = 33
#==========config============



#variables
init_Table = []
temp_string = []
customers_init = []
customers = []
packages_init = []
packages = []
goods = []
sum_us = 0.00

def percent_of_bill (bill, percent_of, price)
	return bill*(price/percent_of)				#.round 2
end


def prepare_line_for_ruby_as_clean_arr (str) 
	temp = str.gsub(/(\n|\r)/,"").split(';')
	result = []
	temp.each do |obj|
		if (obj.to_s.scan(/^\d+\.?\d*$|^\d+,?\d*$/).any?) && (obj.to_s != "")	#scan(/^\d+\.?\d*$|^\d+,?\d*$/) reterns digit; digit.digit; digit,digit
			then result << (obj.sub(",",".").to_f.round 2) 		#obj.scan(...).any?	 returns TRUE if pattern (int or float digit) was found
			else result << obj
		end
	end
	return result
end


def clean_for_csv (str)
	temp = []
	str.each do |obj|
		temp << obj.to_s.sub(".",",") if (obj.class != String && obj.class != Float)
		temp << (obj.round 2).to_s.sub(".",",") if (obj.class == Float)
		temp << obj if obj.class == String
	end
	return temp
end

def number (value, arr) 
	for i in 0...arr.size
		return i if arr[i] == value
	end
	puts "Value \"#{value}\" doesent exists in Array #{arr}"
	return nil
end


def generate_string (from, to, value)
	if from < to
		then result = ";"*from + "-" + value.to_s.sub(".",",") + ";"*(to-from) + value.to_s.sub(".",",")
		else result = ";"*to + value.to_s.sub(".",",") + ";"*(from-to) + "-" + value.to_s.sub(".",",")
	end
	return result
end

def number_to_letter (value)
	all_letters = ["Z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
	result = ""

	first = value/26
	second = value%26
	first = first - 1 if second == 0 


	result = "#{all_letters[first]}" if (first > 0) 
	result = result + "#{all_letters[second]}"
	return result
end

#====================================================processing====================================================

#---read File, init All Customers, all Packages, all Goods
File.open(input_file).each do |line|
	#puts line.inspect
	temp_string = prepare_line_for_ruby_as_clean_arr(line)	#temp_string = line.gsub(/(\n|\r)/,"").split(';')
	init_Table << temp_string
	customers_init << temp_string[c_name]
	goods << temp_string[c_goods]
	packages_init << temp_string[c_track]   #.to_i
	sum_us += temp_string[c_us_price]
	#puts temp_string.inspect
	#puts ""
	end
	
init_Table.each do |line|
#	puts "#{line[c_name].class};#{line[c_goods].class};#{line[c_date_bill].class};#{line[c_track].class};#{line[c_us_price].class};#{line[c_shipping_us].class};#{line[c_price_rub].class};#{line[c_date_purchase].class};#{line[c_admin_purchase].class};#{line[c_bill].class};#{line[c_total].class};#{line[c_date_pay].class};#{line[c_admin_pay].class}"
#	puts "#{line[c_name]};#{line[c_goods]};#{line[c_date_bill]};#{line[c_track]};#{line[c_us_price]};#{line[c_shipping_us]};#{line[c_price_rub]};#{line[c_date_purchase]};#{line[c_admin_purchase]};#{line[c_bill]};#{line[c_total]};#{line[c_date_pay]};#{line[c_admin_pay]}"
	line = clean_for_csv(line)
#	puts "#{line[c_name].class};#{line[c_goods].class};#{line[c_date_bill].class};#{line[c_track].class};#{line[c_us_price].class};#{line[c_shipping_us].class};#{line[c_price_rub].class};#{line[c_date_purchase].class};#{line[c_admin_purchase].class};#{line[c_bill].class};#{line[c_total].class};#{line[c_date_pay].class};#{line[c_admin_pay].class}"
#	puts "#{line[c_name]};#{line[c_goods]};#{line[c_date_bill]};#{line[c_track]};#{line[c_us_price]};#{line[c_shipping_us]};#{line[c_price_rub]};#{line[c_date_purchase]};#{line[c_admin_purchase]};#{line[c_bill]};#{line[c_total]};#{line[c_date_pay]};#{line[c_admin_pay]}"
#	puts ""
end



#-1-Customers total bill
customers_init.uniq.sort.each do |cust|
	customers << [cust, 0.0]
	cash_flow_users << cust 						# = cash_flow_users (^^^"Bobby","Leha","Igor","SHOPS"^^^) + All unique customers (c_name)
end

#-2-Packages list, cosolidation price
packages_init.uniq.sort.each do |pack|
	packages << [pack,0.0]
end
for i in 0...packages.size
	for j in 0...packages_init.size
		packages[i][1]+=1 if packages[i][0] == packages_init[j]
	end
end
packages.each do |pack|
	for i in 0...init_Table.size
		init_Table[i][c_consolidation_price] = 2/pack[1] if init_Table[i][c_track] == pack[0]
	end
end

#-3-Set new fiels
cash_flow_report = []
package_price_wo_consolidation = (package_price*dollar) - (packages.size*2*dollar)


init_Table.each do |line|
	line[c_shipping] = (percent_of_bill(package_price_wo_consolidation, sum_us, line[c_us_price])) + (line[c_consolidation_price]*dollar) + (line[c_shipping_us].to_f*dollar)	# Set shipping price per commodity
	puts "By User #{line[c_name]} [c_bill] and [c_total] are not set" if ((line[c_bill].to_s == "") && (line[c_total].to_s == ""))			# nothing Error
	puts "By User #{line[c_name]} [c_bill] and [c_total] are set together" if ((line[c_bill].to_s != "") && (line[c_total].to_s != ""))		# all together Error
	line[c_bill] = (line[c_total] - line[c_shipping]) if ((line[c_bill].to_s == "") &&(line[c_total].to_s != ""))							# Set Bill
	line[c_total] = (line[c_bill] + line[c_shipping]) if ((line[c_total].to_s == "") && (line[c_bill].to_s != ""))							# Set Total
	for i in 0...customers.size
		customers[i][1] += line[c_total] if customers[i][0] == line[c_name]
	end
	
	#c_date_bill		bby -> cust 										# generate bill = c_total
		from_whom = number("Bobby", cash_flow_users)
		to_whom = number(line[c_name], cash_flow_users)
		bill = line[c_total].round 2
	cash_flow_report << ";#{line[c_goods]};#{line[c_date_bill]};#{generate_string(from_whom, to_whom, bill)}"
	
	#c_date_purchase	adm -> bby 											# c_price_rub -> shop 	(if c_price_rub != 0)
		from_whom = number(line[c_admin_purchase], cash_flow_users)
		to_whom = number("Bobby", cash_flow_users)
		bill = line[c_price_rub].round 2
	cash_flow_report << ";#{line[c_goods]};#{line[c_date_purchase]};#{generate_string(from_whom, to_whom, bill)}" if line[c_price_rub].to_i != 0
	#c_date_purchase	bby -> shop
		from_whom = number("Bobby", cash_flow_users)
		to_whom = number("SHOPS", cash_flow_users)
		bill = line[c_price_rub].round 2
	cash_flow_report << ";#{line[c_goods]};#{line[c_date_purchase]};#{generate_string(from_whom, to_whom, bill)}" if line[c_price_rub].to_i != 0
	
	#c_date_pay		cust -> bby 											# c_total -> adm 	(from customer)
		from_whom = number(line[c_name], cash_flow_users)
		to_whom = number("Bobby", cash_flow_users)
		bill = line[c_total].round 2
	cash_flow_report << ";#{line[c_goods]};#{line[c_date_pay]};#{generate_string(from_whom, to_whom, bill)}" #if line[c_price_rub].to_i != 0
	#c_date_pay		bby -> adm
		from_whom = number("Bobby", cash_flow_users)
		to_whom = number(line[c_admin_pay], cash_flow_users)
		bill = line[c_total].round 2
	cash_flow_report << ";#{line[c_goods]};#{line[c_date_pay]};#{generate_string(from_whom, to_whom, bill)}" #if line[c_price_rub].to_i != 0
	
end

#====================================================Report====================================================

#=begin
last_coloumn_letter = number_to_letter(cash_flow_users.size + 5)		#5 = 3 needed + 2 na zapas
last_string_number = ((init_Table.size)*5) + 20							#20 zapas


#svodnie_dannie_csv
print "\n"
print "All Goods (#{init_Table.size});Customers (#{customers.size});Bill;All Packages (#{packages.size});Quantity\n"
for i in 0...init_Table.size 
	print goods[i]
	print ";"
	print customers[i][0] if i < customers.size
	print ";"
	print ((customers[i][1]).round 2) if i < customers.size
	print ";"
	print packages[i][0] if i < packages.size
	print ";"
	print packages[i][1] if i < packages.size
	print "\n"
end
puts ""



#filled_table_csv
puts "goods;name;consolidation_price;track;us_price;price_rub;shipping;bill;total"
init_Table.each do |line|
	line = clean_for_csv(line)
	puts "#{line[c_goods]};#{line[c_name]};#{line[c_consolidation_price]};#{line[c_track]};#{line[c_us_price]};#{line[c_price_rub]};#{line[c_shipping]};#{line[c_bill]};#{line[c_total]}"
end
puts ""

#cash_flow_report
puts ";Goods;Date;" + cash_flow_users.join(';')
puts "SUM(D2:#{last_coloumn_letter}2);sums;;SUM(D3:D#{last_string_number});"
puts cash_flow_report


#=end