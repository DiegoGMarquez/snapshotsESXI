#!/bin/sh
# Snapshots automaticas en VMware ESXI Host

# Listar y extraer VMID de todas las maquinas virtuales
# listVMID=$(vim-cmd vmsvc/getallvms | awk '$1 ~ /^[0-9]+$/ {print $1}')

# Listar manualmente los VMID
listVMID="15 17 6"

# Extraer fecha actual
date=$(date +"%Y%m%d")

# Recorre todas las VMID
for VMID in ${listVMID}; do
    # Creacion de snapshot de la VM
    vim-cmd vmsvc/snapshot.create $VMID "Snapshot $date" "Creada de forma automatica desde script /Backup/SnapshotsESXI.sh" true true

    # Filtrar y guardar snapshot IDs de la VM
    listSnapshotID=$(vim-cmd vmsvc/snapshot.get $VMID | awk -F': ' '/Snapshot Id/{print $2}')

    # Cantidad de valores del array
    array_length=$(echo "$listSnapshotID" | wc -l)

    # Verificar si hay mas valores que 2, asi elimina las snapshot antiguas a 2 snapshot
    if [ "$array_length" -ge 2 ]; then
        # Utilizar sed para eliminar los dos últimos elementos
        new_listSnapshotID=$(echo "$listSnapshotID" | sed "$((array_length-1)),${array_length}d")
    else
        break
    fi

    # Recorre todos las snapshot con antiguedad a 2 snapshots
    for snapshotID in ${new_listSnapshotID}; do
        # Elimina las snapshots antiguas
        vim-cmd vmsvc/snapshot.remove $VMID $snapshotID
    done
done

