$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:8000/') 
$listener.Start()

$context = $listener.GetContext() 

$request = $context.Request
$response = $context.Response

$rawrequest = $request.RawUrl

function ordercheck {
param ($ordersheet)
if(Test-Path $ordersheet){write-host 'order sheet already exists!' -ForegroundColor Red}
    else{new-item $ordersheet; write-host 'created ordersheet!' -ForegroundColor green}
}

switch -Regex ($rawrequest)
{ '/getrecords$' {
                   #first check if order list exists and if not create it
                   'Order List Check!'
                    $ordersheet = 'C:\temp\ordersheet.csv'
                    ordercheck($ordersheet)
                    #if it's empty ask for the first entry
                    $ordercsv = import-csv $ordersheet
                    if(gc import-csv $ordersheet){
                              $ordertype = read-host 'Order type'
                              [int]$ordernum = read-host 'Order num'
                              $ordercsv | Select-Object *,@{
                                name = 'record_id'
                                expression = {$ordertype}},
                                @{name='ordernum' 
                                expression={$ordernum}}  
                                }
                              $message = $order_record | convertto-json
                              $message >> $ordersheet
                              }}
                        else{
                              $ordertype = read-host 'Order type'
                              [int]$ordernum = read-host 'Order num'
                              $order_record = New-Object -TypeName psobject -Property @{record_name = $ordertype; amount = $ordernum }
                              $message = $order_record | convertto-json
                              $message > $ordersheet
          
                              }
                    pause
                    $listener.Stop()
                    break}
  '/test$' { 'this matches test';  $listener.Stop(); break}
  '/record$' {'this matches add and is a bad way to construct api endpoints :)'; $listener.Stop(); break}
  '/getlast$'{}
  }




if($request.RawUrl -match '/user$'){
"User request!"
$message = $Data.username | ConvertTo-json
$response.ContentType = 'application/json'
[byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
$response.ContentLength64 = $buffer.Length

$output = $response.OutputStream
$output.Write($buffer,0,$buffer.Length)
$output.close

$listener.stop()
}
elseif($request.RawUrl -match '/adduser$'){
'TEST METHOD'
$Data += New-Object -typename psobject -Property @{ UserName = "boydd"; FirstName = "Boyd"; LastName = "Drafus"}
$listener.stop()
}

else{write-host
"NO REQUEST FOUND"
$listener.stop()
}
