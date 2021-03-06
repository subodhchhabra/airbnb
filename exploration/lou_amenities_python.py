
#f = open('amenities_and_id.tsv', 'r+')

file_name = 'unique_amenities_grand.tsv' #change these if you want to work on different files
skinny_table = 'amenities_and_id_grand.tsv'
#print(skinny_table)

grand_amenities = open(file_name).readlines()
list_of_amenities = []
for one_row in grand_amenities[1:len(grand_amenities)]:
    nrow, item = one_row.strip().replace('\"', '').split('\t')
    list_of_amenities.append(item)

#print(list_of_amenities) #prints out all unique amenities in airbnb
#print(len(list_of_amenities)) #43

with open(skinny_table) as f:
    listings = f.readlines() #returns the rownum, id, list of amenities for each line

grand_result = []
amenities_string = "id," + ",".join(list_of_amenities)
temp_arr = amenities_string.split(',')
amenities_string = ",".join(temp_arr)
print(amenities_string)


for listing in listings[1:len(listings)]:
    rownum, id, amenities, scrape_date = listing.split('\t')
    listings_amenities = amenities.replace('{', '').replace('}', '').replace('\\', '').replace('\"', '').strip().split(',') #strip \n and split it by comma and backslash
    #refactor replacements of {, }, \, "
    print(listings_amenities)

    #entering each amenity item within a listing
    true_false_row = [id] #start off with listing ID at the front
    for i in range(0,len(list_of_amenities)): #run for the length of total list of amenities i.e. 43
        item = list_of_amenities[i]
        if item in listings_amenities: #check to see if is contained
            #print(item)
            #print("T")
            #print(i) #tells 'position' of the amenity
            true_false_row.append("TRUE")
        else:
            true_false_row.append("FALSE")
    #print(len(true_false_row))

    row_string = ",".join(true_false_row)
    print(row_string)
