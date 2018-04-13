#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

#define DEV_AMPGPIO_TYPE				'G'
#define GPIO_IOC_PERIPERAL_PIN_NR_GET	_IO(DEV_AMPGPIO_TYPE,0x28)
#define GPIO_IOC_FM_PIN_SCAN			_IO(DEV_AMPGPIO_TYPE,0x29)
#define GPIO_IOC_FM_ADD_GPIO_CHIP		_IO(DEV_AMPGPIO_TYPE,0x2a)
#define GPIO_IOC_FM_RMV_GPIO_CHIP		_IO(DEV_AMPGPIO_TYPE,0x2b)
#define GPIO_IOC_FM_ADD_I2C_DEV			_IO(DEV_AMPGPIO_TYPE,0x2c)
#define GPIO_IOC_FM_RMV_I2C_DEV			_IO(DEV_AMPGPIO_TYPE,0x2d)
#define GPIO_IOC_FM_ADD_SPI_DEV			_IO(DEV_AMPGPIO_TYPE,0x2e)
#define GPIO_IOC_FM_RMV_SPI_DEV			_IO(DEV_AMPGPIO_TYPE,0x2f)
#define GPIO_IOC_FM_ADD_UART_DEV		_IO(DEV_AMPGPIO_TYPE,0x30)
#define GPIO_IOC_FM_RMV_UART_DEV		_IO(DEV_AMPGPIO_TYPE,0x31)

#define SPI_SLAVE_SELECT 1
#define SPI_MASTER_SELECT 0

//#define FM_DEVICE_OP_DEBUG
#if defined (FM_DEVICE_OP_DEBUG)

#define error(...) do {} while (0)

#elifif __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 95)

#define error(...) do {\
	fprintf(stderr, "%s: %d: ", __func__, __LINE__); \
	fprintf(stderr, __VA_ARGS__); \
	putc('\n', stderr); \
} while (0)

#else

#define error(args...) do {\
	fprintf(stderr, "%s: %d: ", __func__, __LINE__); \
	fprintf(stderr, ##args); \
	putc('\n', stderr); \
} while (0)

#endif	

static int xioctl(int fh, int request, void *arg)
{
	int r;
	do {
		r = ioctl(fh, request, arg);
	} while (-1 == r && EINTR == errno);
	return r;
}
static void errno_exit(const char *s)
{
	error("%s error %d, %s\n", s, errno, strerror(errno));
	exit( EXIT_FAILURE );
}

typedef struct _per_chnl_mux_s{
	int channel;
	int pinmux;
}fm_per_chl_mux_t;

#define I2C_SLAVE_SELECT 1
#define I2C_MASTER_SELECT 0
typedef struct _per_chnl_mux_mode_s{
	int channel;
	int pinmux;
	int slave_master;
}fm_spi_para_t;

char* dev = "/dev/gpioctl0";

int add_i2c_dev(int chnl, int pinmux)
{
	fm_per_chl_mux_t data;
	int fd;
	
	data.channel = chnl;
	data.pinmux = pinmux;
	
	fd = open(dev, O_RDWR);
	if (fd < 0){
		error( "open dev [%s] failed\n", dev );
		return -1;
	}
	if ( -1 == xioctl(fd, GPIO_IOC_FM_ADD_I2C_DEV, &data) ) {
		close(fd);
		errno_exit("add i2c failed\n");
		return -1;
	}

	return 0;
}

int remove_i2c_dev(int chnl)
{
	fm_per_chl_mux_t data;
	int fd;
	
	data.channel = chnl;
	fd = open(dev, O_RDWR);
	if (fd < 0){
		error( "open dev [%s] failed\n", dev );
		return -1;
	}
	if ( -1 == xioctl(fd, GPIO_IOC_FM_RMV_I2C_DEV, &data) ) {
		close(fd);
		errno_exit("remove i2c failed\n");
		return -1;
	}
	return 0;
}

int add_spi_dev(int chnl, int pinmux, int is_slave)
{
	fm_spi_para_t data;
	int fd;
	
	data.channel = chnl;
	data.pinmux = pinmux;
	data.slave_master = is_slave? SPI_SLAVE_SELECT: SPI_MASTER_SELECT;

	fd = open( dev,O_RDWR);
	if (fd < 0){
		error( "open dev [%s] failed\n", dev );
		return -1;
	}
	if ( -1 == xioctl(fd, GPIO_IOC_FM_ADD_SPI_DEV, &data) ) {
		close(fd);
		errno_exit("add spi failed\n");
		return -1;
	}
	return 0;
}

int remove_spi_dev(int chnl)
{
	fm_spi_para_t data;
	int fd;
	data.channel = chnl;

	fd = open( dev,O_RDWR);
	if (fd < 0){
		error( "open dev [%s] failed\n", dev );
		return -1;
	}
	if ( -1 == xioctl(fd, GPIO_IOC_FM_RMV_SPI_DEV, &data) ) {
		close(fd);
		errno_exit("remove spi failed\n");
		return -1;
	}
	return 0;
}

int add_uart_dev(int chnl, int pinmux)
{
	fm_per_chl_mux_t data;
	int fd;
	
	data.channel = chnl;
	data.pinmux = pinmux;
	fd = open(dev,O_RDWR);
	if (fd < 0){
		error( "open dev [%s] failed\n", dev );
		return -1;
	}
	if ( -1 == xioctl(fd, GPIO_IOC_FM_ADD_UART_DEV, &data) ) {
		close(fd);
		errno_exit("add uart failed\n");
		return -1;
	}
	return 0;
}

int remove_uart_dev(int chnl)
{
	fm_per_chl_mux_t data;
	int fd;
	
	data.channel = chnl;
	fd = open(dev, O_RDWR);
	if (fd < 0){
		error( "open dev [%s] failed\n", dev );
		return -1;
	}
	if ( -1 == xioctl(fd, GPIO_IOC_FM_RMV_UART_DEV, &data) ) {
		close(fd);
		errno_exit("remove uart failed\n");
		return -1;
	}
	return 0;
}

int fm_pin_scan(int chnl)
{
	fm_per_chl_mux_t data;
	int fd;
	
	data.channel = chnl;
	fd = open(dev, O_RDWR);
	if (fd < 0){
		error( "open dev [%s] failed\n", dev );
		return -1;
	}
	if ( -1 == xioctl(fd, GPIO_IOC_FM_PIN_SCAN, &data) ) {
		close(fd);
		errno_exit("remove uart failed\n");
		return -1;
	}
	return 0;
}

#ifdef __cplusplus
}
#endif