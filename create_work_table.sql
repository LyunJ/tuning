CREATE TABLE `user` (
	`id`	int	NOT NULL primary key auto_increment,
	`name`	varchar(20)	NOT NULL,
	`user_login_id`	varchar(30)	NOT NULL,
	`user_login_pw`	varchar(50)	NOT NULL,
	`user_create_dt`	datetime	NOT NULL	DEFAULT now(),
	`user_update_dt`	datetime	NOT NULL	DEFAULT now(),
	`user_delete_dt`	datetime	NULL
);

CREATE TABLE `work_time` (
	`user_id`	int	NOT NULL,
	`in_time`	datetime	NULL,
	`out_time`	datetime	NULL,
	`work_date`	date	NOT NULL	DEFAULT (current_date),
    primary key (user_id,work_date)
);

CREATE TABLE `pay` (
	`id`	int	NOT NULL primary key auto_increment,
	`user_id`	int	NOT NULL,
	`pay`	int	NULL	DEFAULT 0,
	`create_dt`	datetime	NOT NULL	DEFAULT now(),
	`update_dt`	datetime	NOT NULL	DEFAULT now(),
	`delete_dt`	datetime	NULL
);

ALTER TABLE `work_time` ADD CONSTRAINT `FK_user_TO_work_time_1` FOREIGN KEY (
	`user_id`
)
REFERENCES `user` (
	`id`
);

ALTER TABLE `pay` ADD CONSTRAINT `FK_user_TO_pay_1` FOREIGN KEY (
	`user_id`
)
REFERENCES `user` (
	`id`
);

