#------------------ Route 53 ---------------------
#primary zone

resource "aws_route53_zone" "primary" {
  name              = "${var.domain_name}.com.ng"
  delegation_set_id = "${var.delegation_set}"
}

#www

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www.${var.domain_name}.com.ng"
  type    = "A"

  alias {
    name                   = "${aws_elb.wp_elb.dns_name}"
    zone_id                = "${aws_elb.wp_elb.zone_id}"
    evaluate_target_health = false
  }
}

#dev

resource "aws_route53_record" "dev" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "dev.${var.domain_name}.com.ng"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.wp_dev.public_ip}"]
}

#private zone

resource "aws_route53_zone" "secondary" {
  name   = "${var.domain_name}.com.ng"
  vpc_id = "${aws_vpc.wp_vpc.id}"
}

#db

resource "aws_route53_record" "db" {
  zone_id = "${aws_route53_zone.secondary.zone_id}"
  name    = "db.${var.domain_name}.com.ng"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.wp_db.address}"]
}
