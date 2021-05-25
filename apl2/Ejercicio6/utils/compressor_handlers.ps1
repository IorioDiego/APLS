function CompressTrash {
    Compress-Archive -Path $UNCOMPRESSED_TRASH_PATH -DestinationPath $COMPRESSED_TRASH_PATH
    Remove-Item $UNCOMPRESSED_TRASH_PATH -Recurse

    if(TrashIsEmpty) {
        Remove-Item $INDEX_PATH
    }
}

function UncompressTrash {
    if(Test-Path $COMPRESSED_TRASH_PATH) {
        Expand-Archive -Path $COMPRESSED_TRASH_PATH -DestinationPath $PAPELERA_ROOT_PATH
        Remove-Item $COMPRESSED_TRASH_PATH
    }
}