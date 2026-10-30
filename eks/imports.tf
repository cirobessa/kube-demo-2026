import {
  to = aws_eks_cluster.this
  id = var.cluster_name
}

import {
  to = aws_route_table_association.private[0]
  id = "${aws_subnet.private[0].id}/${aws_route_table.private.id}"
}

import {
  to = aws_route_table_association.private[1]
  id = "${aws_subnet.private[1].id}/${aws_route_table.private.id}"
}
