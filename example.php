<?php

  $dbc = new mysqli("localhost", "user", "password", "database");
  if($dbc->connect_errno) {
    die("Verbindung fehlgeschlagen: " .$dbc->connect_error);
  }

  $id = 100;
  $sql = "SELECT * FROM tabelle WHERE _id < ?";

  $stmt = $dbc->prepare($sql);
  $stmt->bind_param('i', $id);
  $stmt->execute();
   
  $res = $stmt->get_result();

  while($r = $res->fetch_assoc()) {
    echo $r['name'];
  }

?>
