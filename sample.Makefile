APP      = myapp

SRCS     = PracticeMain.cpp
OBJS     = $(SRCS:.cpp=.o)
DEPS     = $(patsubst %.cpp,%.d,$(SRCS))

DEBUG    = -g
INCLUDES =

CXXFLAGS = $(DEBUG) $(INCLUDES) -Wall -pedantic -c
LDFLAGS  =

DEPENDS  = -MT $@ -MD -MP -MF $(subst .o,.d,$@)

.PHONY: all clean


all: $(APP)

$(APP): $(OBJS)
	$(CXX) $^ $(LDFLAGS) -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(DEPENDS) $<

clean:
	$(RM) $(OBJS)
	$(RM) *.d

realclean: clean
	$(RM) $(APP)

ifneq "$(MAKECMDGOALS)" "realclean"
ifneq "$(MAKECMDGOALS)" "clean"
-include $(DEPS)
endif
endif
