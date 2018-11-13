echo "Create Oracle wallet for PBSA stores"
var=2
path="/home/oraapex/wallet${var}"
cer_path=${path}/LSL${var}.cer

echo "Create the wallet folder"
mkdir -p ${path}

echo "Copy the certification file .cer"
cp /tmp/LSL${var}.cer ${path}

echo "Create the wallet"
orapki wallet create -wallet ${path} -pwd Pa$$w0rd -auto_login
orapki wallet add -wallet ${path} -trusted_cert -cert ${cer_path} -pwd Pa$$w0rd