echo "Download SSL .cer for PBSA stores"

var=0
while IFS= read -r line; do
	var1=$((var++))
	echo "" | openssl s_client -host ${line} -port 31058 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'  > LSL${var}.cer

echo "Create Oracle wallet for PBSA stores"
path="/home/oraapex/wallet${var}"
cer_path=${path}/LSL${var}.cer

echo "Create the wallet folder"
mkdir -p ${path}

echo "Copy the certification file .cer"
cp /home/oraapex/LSL${var}.cer ${path}

echo "Create the wallet"
orapki wallet create -wallet ${path} -pwd Pa$$w0rd -auto_login
orapki wallet add -wallet ${path} -trusted_cert -cert ${cer_path} -pwd Pa$$w0rd

done < ip-file.txt