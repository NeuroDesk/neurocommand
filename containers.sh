#!/bin/bash         
                    
_script="$(readlink -f ${BASH_SOURCE[0]})" ## who am i? ##                            
_base="$(dirname $_script)" ## Delete last component from $_script ##                 
source neurodesk/configparser.sh ${_base}/config.ini                                  
                    
install_all_containers="false"                                                        
                    
if [ "$1" != "" ]; then                                                               
    echo "Installing all containers"                                                  
    install_all_containers="true"                                                     
fi                  
                    
echo "------------------------------------"                                           
echo "to install ALL containers, run:"                                                
echo "bash containers.sh --all"                                                       
echo "------------------------------------"                                           
echo "to install individual containers, run:"                                         
while read appsh; do
------              
      echo $appsh run:                                                                
      arrayIn=(${appsh//_/ })                                                         
      appfetch="./local/fetch_containers.sh ${arrayIn[0]} ${arrayIn[1]} ${arrayIn[2]}"
      echo $appfetch                                                                                                                                                
      echo ""       
                    
 if [ "$install_all_containers" = "true" ]; then                                      
         eval $appfetch                                                               
        err=$?      
        if [ $err -eq 0 ] ; then                                                      
            echo "Container successfully installed"                                   
            echo "-------------------------------------------------------------------------------------"
            date    
        else        
            echo "======================================="                            
            echo "!!!!!!! Container install failed !!!!!!"                            
            echo "======================================="                            
            date    
            exit    
        fi          
--------            
    fi              
done < cvmfs/log.txt
                    
echo "------------------------------------"                                           
echo "to install ALL containers, run:"                                                
echo "bash containers.sh --all"                                                       
echo "------------------------------------"                                           
echo "to install individual containers, run the above listed commands for each application"
