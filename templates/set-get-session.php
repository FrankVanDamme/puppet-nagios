<?php
session_start();
if ( !  isset($_GET['action']) ){
    echo "running on host: " . gethostname() . "\n";
    echo "session id:      " . session_id() . "\n";
    echo "date:            " . date("H:i:s") . "\n";
    echo "sessvar:         " . $_SESSION['testvar'] . "\n";
} else {
    switch ($_GET['action']){
        case 'sessid':
            echo session_id();
            break;
        case 'setsessvar':
            $_SESSION['testvar'] = $_GET['sessvarvalue'];
            break;
        case 'getsessvar':
            echo $_SESSION['testvar'];
            break;
    }
}
?>
