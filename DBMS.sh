#!/bin/bash
#export LC_COLLATE=C
#shopt -s extglob
clear
function listDBs {
	  if [[ ! -d ~/DB ]]
	  then
   	 	zenity --width=350 --height=300 --error --text "There is no database."
		Database
	  else
	    dbs=$(ls ~/DB)
	    zenity --width=350 --height=300 --list --title "Databases" --text "List of databases:" --column "Databases" $dbs
	  fi
	Database
}

function createDB {
	  dbname=$(zenity --entry --title "Create Database" --text "Enter the name for the new database:")
	if [ $? -ne 0 ]
		then
			  Database
		fi
 	 if [[ -e ~/DB/$dbname ]]
 	 then
 		   zenity --error --text "This name is already used"
 	 elif [[ $dbname =~ ^[a-zA-Z] ]] && [[ $dbname = +([a-zA-Z0-9_]) ]]
	 then
   	 	zenity --info --text "Valid name"
                mkdir -p ~/DB/$dbname
 	 else
 	       zenity --error --text "Please enter a valid name. It should start with a character and can include numbers or _."
	  fi
	Database
}

function dropDB {
	  dbs=$(ls ~/DB)
	  selected_db=$(zenity --list --title "Databases" --text "Select a database to drop:" --column "Databases" $dbs)
	  if [[ $? -eq 0 ]]
	  then
 	 	rm -r ~/DB/$selected_db
		zenity --info --text "The database '$selected_db' has been dropped successfully."
	  else
		Database
	  fi
	  Database
}
function listTables {
	 tabl_list=$(ls ~/DB/$dbname)
	 zenity --list --title="Select tabl" --text=" the tables in your database :" --column="table Name" $tabl_list
	 useExistingDB
}
function createTable {
  	  tableName=$(zenity --entry --title "Table Name" --text "Enter the name for the Table to create:")
						if [ $? -ne 0 ]
						then
							  useExistingDB
						fi
  	  if [[ -z "$tableName" ]]
	  then
		    zenity --error --text "Please enter a name for the table."
		    createTable
	  fi
	  if [[ -e "$tableName" ]]
	  then
		    zenity --error --text "This name is already used."
		    createTable
	  fi
 	  if ! [[  $tableName =~ ^[a-zA-Z]+([a-zA-Z0-9_])*$ ]]
	  then
		    zenity --error --text "Please enter a valid name that starts with a character and can include numbers or underscores."
		    createTable
	  fi
	  touch "$tableName"
	  numCol=$(zenity --entry --title "Number of Columns" --text "Choose the number for columns:")
	  flag=true
  	  while $flag 
	  do
	  	if ! [[ $numCol = [1-9]*([0-9]) ]]
	       	then
   			 zenity --error --text "Please enter a valid number."
		 	 numCol=$(zenity --entry --title "Number of Columns" --text "Please enter a valid number")
						if [ $? -ne 0 ]
						then
							  createTable
						fi
		else
		       	 flag=false
		fi
	  done
	  
	  flag=true
	  while $flag 
	  do
	  		PK=$(zenity --entry --title "Primary Key" --text "Enter the name of primary key:")
						if [ $? -ne 0 ]
						then
							  createTable
						fi
	  		if ! [[ $PK =~ ^[a-zA-Z]+([a-zA-Z0-9_])*$ ]]
		       	then
	  			  zenity --error --text "Please enter a valid name that starts with a character and can include numbers or underscores."
						
			else
			       	  flag=false
			fi
	 done
 	 echo -n "$PK-" >> "$tableName"
	 dataType=$(zenity --list --title "Data Type" --text "Select the data type:" --column "Data Types" "integer" "string")
						if [ $? -ne 0 ]
						then
							  createTable 
						fi
	 echo -n "$dataType " >> "$tableName"
	 for i in $(seq 2 $numCol)
	 do
			flag=true
			while $flag 
			do
    				colName=$(zenity --entry --title "Column Name" --text "Enter the name for column $i:")
    				if ! [[ $colName =~ ^[a-zA-Z]+([a-zA-Z0-9_])*$ ]]
			       	then
    		  			zenity --error --text "Please enter a valid name that starts with a character and can include numbers or underscores."
				else
				       	flag=false
				fi
			done
			echo -n "$colName" >> "$tableName"
		        dataType=$(zenity --list --title "Data Type" --text "Select the data type:" --column "Data Types" "integer" "string")
						if [ $? -ne 0 ]
						then
							  createTable 
						fi
   			echo -n "-$dataType " >> "$tableName"
	done

  	echo "" >> "$tableName"
 	zenity --info --text "The table '$tableName' has been created successfully."
	useExistingDB
}
function InsertIntoTable {
	tabl_list=$(ls ~/DB/$dbname)
	table_name=$(zenity --list --title="Select tabl" --text="Choose the table you want to use:" --column="table Name" $tabl_list)
	if [ $? -ne 0 ]
	then
		   useExistingDB
	fi
	if ! [[ -f ~/DB/$dbname/$table_name ]]
       	then
    		zenity --error --text="$table_name does not exist."
  		InsertIntoTable
	fi
	colsNum=$(awk ' {if(NR == 1) print NF}' ~/DB/$dbname/$table_name)
	colNames=($(awk 'BEGIN{FS=" "}{ print $0}' ~/DB/$dbname/$table_name))
	arr=()
	 for (( i = 1; i <= $colsNum ; i++ ))
	 do
   		 firstline=$(awk 'BEGIN{FS=" "}{ if(NR == 1) print $0}' ~/DB/$dbname/$table_name  | cut -d ' ' -f$i | awk -F "-" '{print $2}' )
   		 arr[$i-1]=$firstline
	 done
	 for (( i = 0; i <= $colsNum - 1; i++ ))
	 do
	         value=$(zenity --entry --text="Enter value for ${colNames[$i]}: " --title="Insert into table")
	  	 if [ $? -ne 0 ]
		 then
			   InsertIntoTable
	 	 fi
		 check=true
		 if  [[ "${arr[$i]}" = "integer" ]]
		 then
     			 while $check 
     			 do
        			if  [[ "$value" = +([1-9])*([0-9]) ]]
		       		then
         				 if [[ $i == 0 ]]
					 then 
					          checkPK=$(awk '{print $1}' ~/DB/$dbname/$table_name | grep $value)
        					  if [[ -z "$checkPK" ]]
						  then
					         	 checkPK=0	
			        	 	  fi 
		            			  flag=true
					          while $flag
           					  do
    						          if [[ "$value" == "$checkPK" ]]
							  then
						        	        zenity --error --text="primary should key unique"
						                	value=$(zenity --entry --text="Enter value for ${colNames[$i]}: " --title="Insert into table")
							                checkPK=$(awk '{print $1}' ~/DB/$dbname/$table_name | grep $value)
						        	        if [ -z "$checkPK" ]
								       	then
							        	          checkPK=0	
						                	fi 
					                  else 
                							flag=false
          						  fi
        					  done 
     					fi
        				if  [[ "$value" = +([1-9])*([0-9]) ]]
				       	then
        					    values+="$value "
        					    check=false
 	      				fi
    				  else 
  					        zenity --error --text="Enter value must be integer"
        					value=$(zenity --entry --text="Enter value for ${colNames[$i]}: " --title="Insert into table")
      		  		  fi
      		      done
	         else
					 if [[ $value =~ " " ]]
                                         then
                                                 value=${value// /_}
                                         fi				
					values+="$value "

    		 fi

	  done
	  echo "$values" >> ~/DB/$dbname/$table_name
  	  zenity --info --title "Success" --text "Data inserted successfully."
	  values=""
	  useExistingDB
}
function select_column {
	arr_column=()
	colsNum=$(awk ' {if(NR == 1) print NF}' ~/DB/$dbname/$table_name) 
	for (( i = 1; i <= $colsNum ; i++ ))
       	do				
		columns=$(awk 'BEGIN{FS=" "}{ if(NR == 1) print $0}' ~/DB/$dbname/$table_name  | cut -d ' ' -f$i | awk -F "-" '{print $1}' )
		arr_column[$i-1]=$columns
	done
	name_of_culumn=$(zenity --list --title "Select Option" --text "Choose:" --column "Options" "${arr_column[@]}")
	if [ $? -ne 0 ]
	then
		 select_from_table
	fi
	local column_index=$(echo "${arr_column[@]} " | awk -v column="$name_of_culumn" '{
	    for (i = 1; i <= NF; i++) {
	      if ( $i == column ) {
		print i; 
       		 break;
      		}
 	   }
 	 }')
	  values=$(tail -n +2 ~/DB/$dbname/$table_name | awk -v column_index="$column_index" '{print $column_index}')
	  zenity --info --title="Extracted Values" --text="The values from column $column_index are:\n$values"
	  select_column

}
function select_from_table {
	table_name=$(zenity --list --text "Select the table to select from:" --column "Tables" $(ls ~/DB/$dbname))
	if [ $? -ne 0 ]
	then
		 useExistingDB
	fi
        choise=$(zenity --list --title "Select Option" --text "Choose:" --column "Options" "select all" "select row by PK" "select column" "exit")
	case $choise in 
		  	"select all")
			       	zenity --text-info --title "Contents of table_name" --filename ~/DB/$dbname/$table_name 
				select_from_table
				break  ;;
			"select row by PK")
				NumberOfRow=$(zenity --entry --title "select row" --text "Enter id number to select ")
				NR=$(awk '{if( $1 == '$NumberOfRow')print NR}' ~/DB/$dbname/$table_name)
				if [[ $NR == "" ]]
				then
					zenity --error --title "error" --text "$NumberOfRow not exist "
					select_from_table
				else
					value=$(sed -n "${NR}p" ~/DB/$dbname/$table_name)
	  				zenity --info --title="Extracted Values" --text="The values from row witk PK  $NumberOfRow are:\n$value"
					select_from_table
				fi
					;;
		        "select column")
				select_column 
				 ;;
			"exit") 
				useExistingDB 
				;;
			*)echo -e "\033[31m "Invalid option" \033[0m"
				   ;;
	esac

}
function delete_row {
	NumberOfRow=$(zenity --entry --title "delete row" --text "Enter id number to delete ")
	NR=$(awk '{if( $1 == '$NumberOfRow')print NR}' ~/DB/$dbname/$table_name)
	if [[ $NR == "" ]]
	then	
		zenity --error --title "error" --text "$NumberOfRow not exist "
		delete
	else
		sed -i "${NR}d" ~/DB/$dbname/$table_name 
		zenity --info --title "success" --text "row deleted"							
	fi
	delete
}

function delete {
	table_name=$(zenity --list --text "Select the table to delete from:" --column "Tables" $(ls ~/DB/$dbname))
	if [ $? -ne 0 ]
	then
		 useExistingDB
	fi
  	if [[ ! -f ~/DB/$dbname/$table_name ]]
       	then
  		zenity --error --text "Error: The table '$table_name' does not exist."
		delete
	else
		option=$(zenity --list --text "What would you like to do?" --column "Option" "delete_all" "delete_row" "exit")
		if [ $? -ne 0 ]
		then
			  delete
		fi
		case $option in
		      delete_all)
        			echo $(head -n 1 ~/DB/$dbname/$table_name) > ~/DB/$dbname/$table_name
        			zenity --info --text "Deleted all data from table '$table_name' successfully."
				delete
			        ;;
		      delete_row)  delete_row 
			        ;;
		      exit)delete
        			;;
  			      *)
			        zenity --error --text "Invalid option selected."
			        ;;
	        esac
 	fi
}

function updateTable {
	cd ~/DB/$dbname/
	tableName=$(zenity --list --title "Select Table" --text "All tables in $dbname:" --column "Tables"  $(ls  ~/DB/$dbname)) 
 	if [[ -f $tableName ]]
 	then
 		   colsNum=$(awk ' {if(NR == 1) print NF}' ~/DB/$dbname/$tableName)
 		   fields=($(awk 'BEGIN{FS=" "}{ if(NR == 1) {for(i=1;i<=NF;i++)print $i}}' ~/DB/$dbname/$tableName  | cut -d '-' -f1  ))
    		   typeFields=($(awk 'BEGIN{FS=" "}{ if(NR == 1) {for(i=1;i<=NF;i++)print $i}}' ~/DB/$dbname/$tableName  | cut -d '-' -f2  ))   
    	 	   colName=$(zenity --list --title "Select Column" --text "All columns in the table $tableName:" --column "Columns" ${fields[@]})
    		   if [ $? -ne 0 ]
   		   then
   			 zenity --error --text="No Column selected...."
			 updateTable
		   fi
	           count=0
   		   check=false
  		   for i in "${fields[@]}"
		   do
      				count=$((count + 1))
      				if [[ "$colName" = "$i" ]]
			       	then
   			    		 newValue=$(zenity --entry --title "Enter Updating Value" --text "Enter the updating value:")
        				 if [ $? -ne 0 ]
					 then 
						    updateTable
					 fi
					 if [[ $count = 1 ]] 
					 then
						 while true
						 do
						 	uniquePK=$(awk '{if( $1 == '$newValue') print NR}' ~/DB/$dbname/$tableName)
							if [[ $uniquePK = "" ]]
							then
								break
							else

						    		zenity --error --title "Error" --text "$newValue is exist ,PK should be uniqe"
   			    		 			newValue=$(zenity --entry --title "Enter Updating Value" --text "Enter the updating value:")
							fi
						done
					 fi
        				 if [[ $newValue =~ " " ]]
                                         then
                                                 newValue=${newValue// /_}
                                         fi
 				      	 dataTypeCol=${typeFields[$count - 1]}
				         if [[ $dataTypeCol = integer ]]
					 then
        	  				newCheck=true
        	  				while $newCheck
					       	do
        	    				 	if [[ $newValue = +([1-9])*([0-9]) ]]
						       	then
        	      						newCheck=false
        	    					else
        	    		 				 newValue=$(zenity --entry --title "Enter Valid Updating Value" --text "Enter valid updating value:")
        	  		 			 fi
        	  				done
       					fi
        	
        				oldvalues=($(awk '{if(NR > 1) print $'$count'}' ~/DB/$dbname/$tableName))
       				 	choise=$(zenity --list --title "Select Option" --text "Choose:" --column "Options" "without condition" "with PK condition")
        	 			if [ $? -ne 0 ]
				       	then
						updateTable
		      		        fi
					case $choise in
					  "without condition")
						  if [[ $count = 1 ]]
						  then
  							check=true
 				 			zenity --error --text="you can't change the PK Coulmn"
							 break 
						  fi
					  			  for old in "${oldvalues[@]}"
								  do
					  			 	   sed -i "s/$old/$newValue/g"  ~/DB/$dbname/$tableName
					  			  done
								  check=true
								  zenity --info --text "The column  has been updated."
								  updateTable
								  ;;
				  
					  "with PK condition")
								    where=$(zenity --entry --title "Enter the Value of PK" --text "Enter the value of PK:")
								    NR=$(awk '{if( $1 == '$where') print NR}' ~/DB/$dbname/$tableName)
						   		    if [[ $NR == "" ]]
								    then
						    				  zenity --error --title "Error" --text "$where not exist"
										  updateTable
							   	    else
					     					 old=$(awk '{if(NR == '$NR') print $'$count'}' ~/DB/$dbname/$tableName)
					     			 		 sed -i "${NR}s/$old/$newValue/" ~/DB/$dbname/$tableName
								    fi
								    check=true
								    zenity --info --text "The column  has been updated."
						       		    updateTable
							    	 	;;

					esac			 
			fi
		done
			if [[ "$check" = false ]]
	       		then
 				 zenity --error --text="No column called $colName"
			fi
		else
		 	 zenity --error --text="Not a valid table"
		fi
	        useExistingDB    
}


##############################
function dropTable {
	  tableName=$(zenity --list --title "Select Table" --text "All tables in $dbname:" --column "Tables"  $(ls  ~/DB/$dbname))
	  if [ $? -ne 0 ]
	  then
		    useExistingDB
	  fi
	  if [[ -e $tableName ]]
	  then
		zenity --question --text "Are you sure you want to drop the table $tableName?"
		if [[ $? == 0 ]]
		then
			rm $tableName
			zenity --info --text "The table $tableName has been successfully dropped."
			useExistingDB
		else 
			dropTable
		fi
	  else
		zenity --error --text "There is no table called $tableName."
		dropTable
	  fi
}
function useExistingDB {
  	db_list=$(ls ~/DB)
  	dbname=$(zenity --list --title="Select DB" --text="Choose the DB you want to use:" --column="DB Name" $db_list)
	if [ $? -ne 0 ]
	then
		    Database
	fi
	if [ ! -e ~/DB/$dbname ]
	then
		    zenity --error --text="Selected DB does not exist. Exiting..."
		    exit 1
	fi
	cd ~/DB/$dbname
  

 	option=$(zenity --list --title="Select Option" --text="Choose an option:" --column="Option" "listTables" "createTable" "dropTable" "updateTable" "InsertIntoTable"  "deleteFromTable" "selectFromTable" "exit")

 	 case $option in 
 		    listTables) listTables ;;
 		    createTable) createTable ;;
		    dropTable) dropTable ;;
		    updateTable) updateTable ;;
		    InsertIntoTable) InsertIntoTable ;;
		    deleteFromTable) delete ;;
		    selectFromTable) select_from_table ;;
		    exit) Database;;
	esac
}


function Database {
		selected=$(zenity --width=350 --height=300 --list --title "Database Manager" --text "Choose a database operation:" --radiolist --column "" --column "Operation" TRUE "Create Database" FALSE "Drop Database" FALSE "Use Existing Database" FALSE "List Databases" FALSE "Exit");

		case $selected in
			  "Create Database")
					    createDB
					    ;;
			  "Drop Database")
					    dropDB
					    ;;
			  "Use Existing Database")
					    useExistingDB
					    ;;
			  "List Databases")
					    listDBs
					    ;;
			  "Exit")
					    exit
					    ;;
		esac
					if [ $? -ne 0 ]
				       	then
						return
		      		        fi
}
	Database
